Please write a pull request title and description I can copy paste into GitHub. Please do this for the work that is on the current branch. Check the commit history and diff to find out what the updates on this branch are. We will be merging into main. Please share in a single code block so I can copy paste.

## PR Description Structure

Include these sections as appropriate:

### Required Sections
- **Summary** - Brief description of what the PR does
- **Changes** - Bullet list of key changes
- **Testing** - How to test / what was tested

### Conditional Sections (include if applicable)

**Rollback Plan** - Include if the change:
- Modifies database schema
- Changes payment/billing logic
- Affects auth/session handling
- Involves data migrations

**Inngest Job Flags** - Flag prominently if PR includes:
- New Inngest functions that perform bulk operations
- Jobs that send notifications (email, push, SMS)
- Jobs that interact with external payment APIs
- Jobs that modify user balances or financial data

Example flag: `INNGEST: This PR adds a bulk notification job - review for rate limits`

**Dependencies** - Note any new packages added
**Breaking Changes** - Note any breaking changes
