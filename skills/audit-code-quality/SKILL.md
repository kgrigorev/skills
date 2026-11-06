---
name: audit-code-quality
description: >-
  Use when asked for a code quality audit, quality pass, or code-smell review
  of a whole project or subproject, especially one too large for a single
  reviewer to read in full. Skip for reviewing a diff or a few files, for
  style-guide conformance, and for security review.
---

# audit-code-quality

## Overview

A `code-quality-auditor` agent audits one scope in a single pass and cannot
start other agents. This skill sizes the target, splits it into batches when
needed, starts one auditor per batch in parallel, and merges their reports
into one. The audit is read-only: never edit the target.

## Procedure

1. **Fix the target.** It is a repo-relative subproject path, such as
   `services/api`. If the user named none, ask; do not pick one.
2. **Measure it.** From the repo root, count lines of authored code:

   ```bash
   git ls-files <target> | grep -vE '(^|/)(vendor|node_modules)/|\.lock$|lock\.(json|yaml)$|_gen\.|\.pb\.|generated' | xargs wc -l | tail -1
   ```

   The count includes docs and config, so source is somewhat lower.
3. **Pick the split.**

   | Authored lines | Split |
   |---|---|
   | under ~10k | one auditor on the whole target |
   | ~10k–20k | one auditor, or per batch when packages are independent |
   | over ~20k | per batch |

   A batch is one package as the language defines it (a Go package, a Python
   package, a .NET project, a top-level `src/` module), or several small
   ones grouped to about 5–10k lines. Leave out vendored and generated code.
4. **Start the auditors.** Send every `code-quality-auditor` call in one
   message so they run in parallel. Each prompt gives the target path and
   that batch's packages. If the repo defines no such agent, start
   general-purpose read-only agents with the same brief: cognitive load,
   readability, idiomatic use, conciseness, and YAGNI/KISS, findings ranked
   by impact with file and line.
5. **Merge.** When all have reported:
   - remove duplicate findings;
   - combine a pattern found in several batches into one finding that lists
     every location;
   - re-check each high-impact finding yourself against its callers and
     tests, and drop any that do not hold up;
   - join the coverage lists and flag any package no auditor covered.
6. **Report** in the auditor's output format: coverage, findings by goal,
   left alone, incidental defects, and a per-goal summary with one verdict.

Use a Workflow instead of plain parallel agents only when the user asked for
one, for example to add a separate verifier per finding.

## Common mistakes

- Starting auditors one per message, which runs them in sequence.
- Splitting by goal instead of by package: each auditor then loses the rule
  that a higher goal wins over a lower one.
- Passing reports through unmerged, so one pattern appears as N findings.
