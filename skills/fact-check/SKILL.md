---
name: fact-check
description: "Fact-check the claims in written text (docs, PR bodies, tickets, handoffs, commit messages) against the code, commands and history they describe. Use before you publish or merge text that makes claims about code, and when you review a docs-heavy diff."
---

# Fact-check

Text about code is read by people and agents who trust it, so each wrong name, count or history
line becomes their wrong turn. This procedure lists every checkable claim in the text and checks
each one against its primary source: the file at the head, the command's real output, the git or
PR history.

The check is read-only. Run commands that only read, and report each fix as corrected text for the
author to apply. A reader that did not write the text finds more: when your harness can start a
subagent with a fresh context, give it the head, where the text is, and this file's path.

## Procedure

1. **Scope.** Fix the head (a commit, a branch, or a PR's head commit) and the text to check:
   - a diff of docs: `git diff <base>..<head> -- <paths>`, with `<base>` from
     `git merge-base <base branch> <head>`;
   - a PR title and body: `gh pr view <n> --json title,body,headRefOid`, or the host's equivalent;
   - commit messages: `git log --format=%B <base>..<head>`;
   - a ticket, handoff or brief: the file at the head, or the text you were given.

   Read files at the head (`git show <head>:<path>`, or its worktree), unless the text says it
   describes another revision, such as `main` or a merged commit. When the host is out of reach,
   use the local head and say so. When there is no text to check, say so and stop.
2. **Claims.** From each added or changed line, list every checkable claim. A removed line is
   right to remove only when its claim no longer holds or another line still makes it.
   - a symbol, flag or command, and what it does;
   - a path, `file:line` or package;
   - a count ("38 calls", "seven edits", "200 lines");
   - a command and what it prints or exits with;
   - history: what a commit or PR changed, when, and which files; a commit id that is still
     current after a squash or rebase;
   - quoted text: a message, help line or doc sentence;
   - a cross-reference: another doc, issue or PR, its number, title or status; a summary of
     another source (notes, a changelog, a diff), which claims every item there appears here or
     says it is partial;
   - what a user or operator sees, including the error they can act on.
3. **Verify.** Check each claim against its cheapest primary source:
   - run the command and compare its output and exit code; for a command that writes or needs
     secrets, read its source instead and name the claim as checked from source;
   - read the file at the head; count by running the search, never by estimate;
   - for history, use `git log`, `git log -S<text>`, `git show <commit>` and
     `gh pr view <n> --json files,commits,mergedAt`.

   A planned symbol ("add `parseConfig`") is a claim of intent: confirm only that it does not
   already exist under another name. An owner decision is unverifiable unless a commit, PR, issue
   or doc records it; name what corroborates it. When two lines of the text disagree, the claim is
   wrong; the correct fact is the line that the primary source supports.

## Done

Done when every claim from step 2 has a verdict (holds, wrong, or unverifiable) and the report
lists every wrong and every unverifiable claim.

Report wrong claims first, each with its location (`path:line`, or the section of a PR body or
brief), the claim, the correct fact, the command or file that shows it, and the corrected text.
Then unverifiable claims, each with what you tried. Then one line with the number of claims that
hold. End with a verdict: "claims check" or "N wrong, M unverifiable".
