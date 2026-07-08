#!/usr/bin/env swift
//
// clipboard-sync — share the clipboard (text AND images) between the two macOS
// user accounts that share this machine.
//
// macOS pasteboards are per-GUI-session: each logged-in user has their own
// NSPasteboard, so there is nothing to "configure" to share one. Instead each
// user runs this as a per-user launchd agent (com.dotfiles.clipboard-sync). The
// agent mirrors its own clipboard out to a shared file in /Users/Shared and
// pulls in whatever the other user last copied — giving the illusion of one
// shared clipboard.
//
// Sync uses a tiny "meta" file (monotonic sequence + which user wrote it) so a
// daemon never re-imports its own writes, and the payload is a binary plist of
// the pasteboard items (one dict of type -> data per item) for full fidelity.
//
// Requires /usr/bin/swift (Xcode Command Line Tools). Runs forever; launchd
// keeps it alive and restarts it on login.

import Foundation
import AppKit

let me = NSUserName()
let syncDir = "/Users/Shared/clipboard-sync"
let payloadPath = "\(syncDir)/clip.archive"
let tmpPath = "\(syncDir)/.clip.archive.tmp"
let metaPath = "\(syncDir)/clip.meta"
let logPath = "\(NSHomeDirectory())/Library/Logs/clipboard-sync.log"

let pollInterval: useconds_t = 500_000          // 0.5s
let maxBytes = 25 * 1024 * 1024                  // skip pathologically large clips

// What we mirror: text + images (extend this list to sync more types).
let allowedTypes: [NSPasteboard.PasteboardType] = [.string, .rtf, .html, .png, .tiff, .pdf]

// Password managers tag copies with these so clipboard tools leave them alone.
// We honour that and never sync a concealed/transient item between sessions.
let secretMarkers: Set<String> = [
    "org.nspasteboard.ConcealedType",
    "org.nspasteboard.TransientType",
]

let fm = FileManager.default

func log(_ msg: String) {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let line = "\(df.string(from: Date())) \(msg)\n"
    guard let data = line.data(using: .utf8) else { return }
    if let fh = FileHandle(forWritingAtPath: logPath) {
        fh.seekToEndOfFile(); fh.write(data); fh.closeFile()
    } else {
        try? data.write(to: URL(fileURLWithPath: logPath))
    }
}

func readMeta() -> (seq: Int, origin: String) {
    guard let raw = try? String(contentsOfFile: metaPath, encoding: .utf8) else { return (0, "") }
    let parts = raw.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ", maxSplits: 1)
    guard parts.count == 2, let seq = Int(parts[0]) else { return (0, "") }
    return (seq, String(parts[1]))
}

func writeMeta(seq: Int, origin: String) {
    try? "\(seq) \(origin)\n".write(toFile: metaPath, atomically: true, encoding: .utf8)
    try? fm.setAttributes([.posixPermissions: 0o660], ofItemAtPath: metaPath)
}

// Snapshot the local pasteboard as [[type: data]], or nil if there's nothing
// worth syncing (empty, too big, or a secret we must not propagate).
func snapshotLocal() -> [[String: Data]]? {
    guard let items = NSPasteboard.general.pasteboardItems else { return nil }
    var out: [[String: Data]] = []
    var total = 0
    for item in items {
        let rawTypes = Set(item.types.map { $0.rawValue })
        if !rawTypes.isDisjoint(with: secretMarkers) {
            log("skip export: concealed/transient item")
            return nil
        }
        var dict: [String: Data] = [:]
        for type in allowedTypes where item.types.contains(type) {
            if let d = item.data(forType: type) {
                dict[type.rawValue] = d
                total += d.count
            }
        }
        if !dict.isEmpty { out.append(dict) }
    }
    if out.isEmpty { return nil }
    if total > maxBytes { log("skip export: \(total) bytes > cap"); return nil }
    return out
}

func exportLocal() -> Bool {
    guard let snap = snapshotLocal() else { return false }
    do {
        let data = try PropertyListSerialization.data(fromPropertyList: snap, format: .binary, options: 0)
        try data.write(to: URL(fileURLWithPath: tmpPath))
        try? fm.setAttributes([.posixPermissions: 0o660], ofItemAtPath: tmpPath)
        // Rename into place AFTER it's fully written, so a reader that has just
        // seen the new meta seq always finds a complete payload.
        if fm.fileExists(atPath: payloadPath) { try? fm.removeItem(atPath: payloadPath) }
        try fm.moveItem(atPath: tmpPath, toPath: payloadPath)
        return true
    } catch {
        log("export error: \(error)")
        return false
    }
}

func applyRemote() -> Bool {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: payloadPath)),
          let obj = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
          let items = obj as? [[String: Data]] else { return false }
    var pbItems: [NSPasteboardItem] = []
    for dict in items {
        let pbItem = NSPasteboardItem()
        for (rawType, d) in dict {
            pbItem.setData(d, forType: NSPasteboard.PasteboardType(rawType))
        }
        pbItems.append(pbItem)
    }
    guard !pbItems.isEmpty else { return false }
    NSPasteboard.general.clearContents()
    return NSPasteboard.general.writeObjects(pbItems)
}

// --- main loop ---------------------------------------------------------------
// Adopt the current state on startup (don't clobber the local clipboard on
// login); only react to changes from here on.
var lastSeenLocalChange = NSPasteboard.general.changeCount
var lastSyncSeq = readMeta().seq
log("clipboard-sync started as \(me) (seq=\(lastSyncSeq))")

while true {
    // 1. Pull in a remote change (anything the other user copied).
    let meta = readMeta()
    if meta.seq != lastSyncSeq {
        lastSyncSeq = meta.seq
        if meta.origin != me, applyRemote() {
            // Applying bumped our local changeCount — record it so step 2 below
            // doesn't mistake the import for a fresh local copy and echo it back.
            lastSeenLocalChange = NSPasteboard.general.changeCount
            log("imported seq \(meta.seq) from \(meta.origin)")
        }
    }

    // 2. Push out a local change (something we just copied).
    let cc = NSPasteboard.general.changeCount
    if cc != lastSeenLocalChange {
        lastSeenLocalChange = cc
        if exportLocal() {
            let newSeq = lastSyncSeq + 1
            writeMeta(seq: newSeq, origin: me)
            lastSyncSeq = newSeq          // ignore our own write on the next tick
            log("exported seq \(newSeq)")
        }
    }

    usleep(pollInterval)
}
