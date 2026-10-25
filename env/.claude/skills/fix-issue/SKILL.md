---
name: fix-issue
description: Fix a GitHub issue
argument-hint: "<issue-number>"
disable-model-invocation: true
---
Analyze and fix the GitHub issue: $ARGUMENTS.

If no issue number was given, ask for one and stop.

1. Use `gh issue view $ARGUMENTS --comments` to get the issue details
2. Understand the problem described in the issue. If it is unclear or not reproducible, ask before writing code
3. Search the codebase for relevant files
4. Create a branch `fix/$ARGUMENTS-<short-desc>` from the up-to-date default branch. Never work on main
5. Write a test that reproduces the issue and confirm it fails
6. Implement the minimal change that makes the test pass
7. Run the project's gates from CLAUDE.md (tests, linting, type checking)
8. Commit with a Conventional Commits message and push
9. Create a PR whose body contains `Closes #$ARGUMENTS`. Never merge it
