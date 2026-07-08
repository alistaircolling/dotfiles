Please review all of the changes on the currently checked out branch. There is a PR for it.

First, determine the correct base branch to diff against by running:
```
gh pr view --json baseRefName --jq '.baseRefName'
```
Use that base branch for all diffs (do NOT assume main). Make sure you have the latest base branch by running `git fetch origin <base-branch>` before diffing. Then do a thorough check of all changes by diffing against `origin/<base-branch>`. Take as much time as you need.

The main things to check are:
- What is the aim of this pull request, what does it add to our application?
- Is the architecture clean and in keeping with similar functionality patterns used in the project?
- Are there flows or user actions related to this feature?
- Does this code affect or break any of these related features?
- Will the app retain all existing functionality that is on the base branch?
- Are there any bugs in this pull request?
- Are there any security risks added in this branch?
- Anything else you think is relevant

## Linear Ticket Cross-Check

Find the associated Linear ticket for this PR. Check the branch name for a ticket identifier (e.g. `abc-1234`), and also check the PR description for any Linear links or ticket references. If you can find one, fetch the ticket details from Linear.

Then perform a **requirements vs implementation audit**:

1. Read the Linear ticket requirements/description and acceptance criteria carefully
2. Read the PR description
3. Review the actual code changes

Compare all three and produce a clear **Requirements Consistency Report** section in your review. Flag the following with prominent warnings (use ⚠️ and bold text):

- **Missing requirements**: Anything specified in the Linear ticket that is NOT addressed in the code changes
- **Undocumented work**: Significant changes in the code that are NOT mentioned in the Linear ticket or PR description
- **Conflicting implementation**: Code that contradicts or deviates from the stated requirements
- **PR description gaps**: Requirements from the Linear ticket that are missing from the PR description
- **PR description extras**: Things mentioned in the PR description that are NOT requirements of the Linear ticket (scope creep, unrelated changes, or items that should be separate tickets)
- **PR description vs ticket conflicts**: Anything in the PR description that contradicts or conflicts with what the Linear ticket specifies

If everything is consistent, state that clearly. If there are discrepancies, list each one explicitly so they can be resolved before merge.

If no Linear ticket can be found, note this in the review and skip the cross-check.

Please create a markdown file with all of this information in.

Please ask if you require clarification on anything. Also check related files to understand how related features work if this update has changed any of their code.
