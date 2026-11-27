---
name: fact-check
description: "Fact-check written claims about code against the files, commands and history they describe. Use before you publish or merge docs, a PR body, a ticket or a handoff, and when you review a docs-heavy diff."
---

# Fact-check

Text about code is read by people and agents who trust it, so each wrong name, count or history
line becomes their wrong turn.

Change nothing the author owns: no edits, commits or pushes in the repository under review, and no
remote writes. Report each fix as corrected text for the author to apply. Running a command that
writes only to a fresh temp folder, `git fetch`, and a detached worktree for the head are fine. A
reader that did not write the text finds more: when your harness can start a subagent with a fresh
context, give it the head, where the text is, and this file's path.

## Procedure

1. **Scope.** Pin the head (a commit, a branch, or a PR's head commit) and the text to check:
   - a diff of docs from the merge base;
   - a PR title and body, with its head commit (`headRefOid` in `gh pr view --json`);
   - the commit messages in the range;
   - a ticket, handoff or brief: the file at the head, or the text you were given.

   Read files at the head, unless the text says it describes another revision, such as `main` or a
   merged commit. When the host is out of reach, use the local head and say so. When there is no
   text to check, say so and stop. Done when you have the head's commit id and the full text.
2. **Claims.** From each line in scope (each added, changed or removed line of a diff, or every
   line of a body, message, ticket or file you were given whole), list every checkable claim:
   - a symbol, flag or command, and what it does;
   - a path, `file:line` or package;
   - a count ("38 calls", "seven edits", "200 lines");
   - a command and what it prints or exits with;
   - history: what a commit or PR changed, when, and which files; a commit id that is still
     current after a squash or rebase;
   - quoted text: a message, help line or doc sentence;
   - a cross-reference: another doc, issue or PR, its number, title or status;
   - a summary of another source (notes, a changelog, a diff): unless it says it is partial, check
     that every item in the source appears in it;
   - what a user or operator sees, including the error they can act on.

   Done when each line in scope has been read and either has its claims listed or holds none.
3. **Verify.** Check each claim against its cheapest primary source:
   - run the command and compare its output and exit code. Run it in a checkout of the head. When
     the only checkout is at another revision, first confirm with
     `git diff --stat <checkout> <head> -- <paths the command reads>` that those paths match, and
     say so; otherwise read the source at the head. For a command that writes elsewhere or needs
     secrets, read its source instead of running it. Mark either case as checked from source;
   - read the file at the head; count by running the search, never by estimate;
   - for history, `git log -S<text>` finds the commit that added or removed a string.

   For a removed line, judge the removal: it holds when the claim is false at the head or another
   line still makes it, and it is wrong when the claim is still true and no line makes it; give
   the text to restore. A planned symbol
   ("add `parseConfig`") is a claim of intent: confirm only that it does not already exist under
   another name. An owner decision is unverifiable unless a commit, PR, issue or doc records it;
   name what corroborates it. When two lines of the text disagree, the claim is wrong; the correct
   fact is the line that the primary source supports. When a claim can be read two ways and one
   reading is false, the claim is wrong: give the false reading, the evidence, and corrected text
   with one reading. Done when each claim has a verdict (holds, wrong, or unverifiable) and the
   file or command behind it.

## Done

Done when every claim from step 2 has a verdict and the report lists every wrong and every
unverifiable claim.

Report wrong claims first, each with its location (`path:line`, or the section of a PR body or
brief), the claim, the correct fact, the command or file that shows it, and the corrected text.
Then unverifiable claims, each with what you tried. Then one line with the number of claims that
hold. End with a verdict: "claims check" or "N wrong, M unverifiable".
