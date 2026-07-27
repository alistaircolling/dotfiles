#!/usr/bin/env node
// Local static server for the tldraw canvas app, plus a small document API.
// Binds to 127.0.0.1 only — nothing here is exposed off the machine.
//
//   GET  /                    -> the canvas app (dist/)
//   GET  /api/doc?name=X      -> the spec JSON for document X
//   POST /api/doc?name=X&client=C -> save edits made on the canvas
//   GET  /api/events?doc=X&client=C -> SSE stream, emits `update` when X changes
//   GET  /api/status?doc=X    -> { clients } so the CLI knows if a tab is open
//
// Usage: server.mjs <port> <dist-dir> <docs-dir>

import { createReadStream, watch } from 'node:fs'
import { readFile, rename, stat, writeFile } from 'node:fs/promises'
import { createServer } from 'node:http'
import { extname, join, normalize, resolve } from 'node:path'

const [, , portArg, distArg, docsArg] = process.argv
const PORT = Number(portArg)
const DIST = resolve(distArg)
const DOCS = resolve(docsArg)

if (!PORT || !distArg || !docsArg) {
	console.error('usage: server.mjs <port> <dist-dir> <docs-dir>')
	process.exit(2)
}

const MIME = {
	'.html': 'text/html; charset=utf-8',
	'.js': 'text/javascript; charset=utf-8',
	'.mjs': 'text/javascript; charset=utf-8',
	'.css': 'text/css; charset=utf-8',
	'.json': 'application/json; charset=utf-8',
	'.svg': 'image/svg+xml',
	'.png': 'image/png',
	'.woff2': 'font/woff2',
	'.woff': 'font/woff',
	'.ttf': 'font/ttf',
	'.otf': 'font/otf',
	'.map': 'application/json; charset=utf-8',
}

// Document names come from the CLI and the query string; keep them to a safe set
// so nothing can escape the docs directory.
const safeName = (name) => (/^[A-Za-z0-9._-]+$/.test(name ?? '') ? name : null)
const docPath = (name) => join(DOCS, `${name}.json`)

/** doc name -> Set of SSE responses currently watching it */
const clients = new Map()
/** doc name -> id of the client whose own save triggered the next watch event */
const selfWrite = new Map()
const debounce = new Map()

// A save round-trips through the file so the CLI and every tab see the same
// bytes — but the tab that made the edit must not be told to redraw itself.
function scheduleBroadcast(name) {
	clearTimeout(debounce.get(name))
	debounce.set(
		name,
		setTimeout(() => {
			debounce.delete(name)
			// A single save can surface as more than one filesystem event, so the
			// marker is held for a short window rather than consumed on the first.
			const author = selfWrite.get(name)
			if (author && author.until <= Date.now()) selfWrite.delete(name)
			for (const res of clients.get(name) ?? []) {
				if (author && author.until > Date.now() && res.clientId === author.client) continue
				res.write('event: update\ndata: 1\n\n')
			}
		}, 60)
	)
}

// One watcher for the whole directory; fs.watch on macOS reports the filename.
// A single save can emit several events, hence the debounce above.
try {
	watch(DOCS, (_event, filename) => {
		if (!filename?.endsWith('.json')) return
		scheduleBroadcast(filename.slice(0, -'.json'.length))
	})
} catch (err) {
	console.error(`tldraw server: cannot watch ${DOCS}: ${err.message}`)
}

const MAX_BODY = 4 * 1024 * 1024

function readBody(req) {
	return new Promise((resolve, reject) => {
		let body = ''
		req.on('data', (chunk) => {
			body += chunk
			if (body.length > MAX_BODY) {
				reject(new Error('document too large'))
				req.destroy()
			}
		})
		req.on('end', () => resolve(body))
		req.on('error', reject)
	})
}

function serveStatic(res, urlPath) {
	// Resolve inside DIST, falling back to index.html for the app shell.
	const rel = normalize(decodeURIComponent(urlPath)).replace(/^(\.\.[/\\])+/, '')
	let file = join(DIST, rel)
	if (!file.startsWith(DIST)) file = join(DIST, 'index.html')

	stat(file)
		.then((s) => (s.isDirectory() ? join(file, 'index.html') : file))
		.catch(() => join(DIST, 'index.html'))
		.then((target) => {
			res.writeHead(200, { 'content-type': MIME[extname(target)] ?? 'application/octet-stream' })
			createReadStream(target)
				.on('error', () => res.end())
				.pipe(res)
		})
}

const server = createServer((req, res) => {
	const url = new URL(req.url, 'http://127.0.0.1')

	if (url.pathname === '/api/doc' && req.method === 'POST') {
		const name = safeName(url.searchParams.get('name'))
		if (!name) return json(res, 400, { error: 'bad document name' })
		return readBody(req).then(
			async (body) => {
				try {
					JSON.parse(body)
				} catch {
					return json(res, 400, { error: 'body is not valid JSON' })
				}
				// Mark the author before writing so the watch events skip them.
				const author = url.searchParams.get('client')
				if (author) selfWrite.set(name, { client: author, until: Date.now() + 750 })
				const tmp = `${docPath(name)}.tmp`
				await writeFile(tmp, body)
				await rename(tmp, docPath(name))
				json(res, 200, { ok: true })
			},
			(err) => json(res, 413, { error: err.message })
		)
	}

	if (url.pathname === '/api/doc') {
		const name = safeName(url.searchParams.get('name'))
		if (!name) return json(res, 400, { error: 'bad document name' })
		return readFile(docPath(name), 'utf8').then(
			(body) => {
				res.writeHead(200, { 'content-type': MIME['.json'], 'cache-control': 'no-store' })
				res.end(body)
			},
			() => json(res, 404, { error: 'no such document' })
		)
	}

	if (url.pathname === '/api/status') {
		const name = safeName(url.searchParams.get('doc'))
		return json(res, 200, { clients: name ? (clients.get(name)?.size ?? 0) : 0 })
	}

	if (url.pathname === '/api/events') {
		const name = safeName(url.searchParams.get('doc'))
		if (!name) return json(res, 400, { error: 'bad document name' })
		res.writeHead(200, {
			'content-type': 'text/event-stream',
			'cache-control': 'no-cache',
			connection: 'keep-alive',
		})
		res.write('retry: 1000\n\n')
		res.clientId = url.searchParams.get('client') ?? ''
		if (!clients.has(name)) clients.set(name, new Set())
		clients.get(name).add(res)
		// Keep-alive comment; also lets us notice a closed tab promptly.
		const ping = setInterval(() => res.write(': ping\n\n'), 20000)
		req.on('close', () => {
			clearInterval(ping)
			clients.get(name)?.delete(res)
		})
		return
	}

	serveStatic(res, url.pathname)
})

function json(res, code, body) {
	res.writeHead(code, { 'content-type': MIME['.json'], 'cache-control': 'no-store' })
	res.end(JSON.stringify(body))
}

server.listen(PORT, '127.0.0.1', () => {
	console.log(`tldraw canvas server on http://127.0.0.1:${PORT} (docs: ${DOCS})`)
})
