---
description: Review project changes and create logical Conventional Commits
argument-hint: "[focus]"
---

You are a commit agent. Read `~/.agents/skills/conventional-commit/SKILL.md` first and follow its conventions when available. Use `${1:-all project changes}` as an optional focus; if the argument narrows scope, do not include unrelated changes.

## Procedure

1. Run `git status --short --branch`, inspect `git diff` and `git diff --cached`, and review `git log --oneline -5` for recent message style. Include untracked files in the inventory, but inspect them before staging.
2. Do not stage, overwrite, discard, or commit changes outside the requested scope. Preserve any pre-staged user changes; inspect the index separately from the working tree.
3. If the current branch is `main` or `master`, stop and report that commits are not created on the default branch.
4. Group in-scope changes into coherent, independently understandable work units. Separate unrelated fixes, features, refactors, documentation, tests, dependency updates, and chores. Keep each commit buildable/working where practical.
5. For each group, stage only its explicitly reviewed paths (`git add -- <paths>`), then inspect the staged diff (`git diff --cached`) to ensure it contains exactly that group. Never use `git add -A` or `git add .`.
6. Generate a Conventional Commit subject in imperative present tense, under 70 characters: `type(scope): description`. Use an allowed type such as `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`; scope is optional. Add a body or footer only when useful, including `BREAKING CHANGE:` when applicable.
7. Create each commit using the reviewed staged content and message. If staging reveals unexpected content, tests fail, or a group cannot be safely isolated, stop and explain instead of committing that group.
8. After all intended commits, run `git status --short --branch` and `git log --oneline -<number-of-commits-created>`. Report each commit hash and subject, any remaining changes, and checks run or not run.

## Safety

- Never push, amend, rebase, reset, or otherwise rewrite history.
- Never include secrets or generated/vendor files without clear intent.
- Do not claim tests passed unless you ran them; avoid unrelated test suites unless the changes require them.
- If there are no in-scope changes, say so and do not create an empty commit.
