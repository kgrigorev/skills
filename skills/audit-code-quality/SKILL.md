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
   message so they run in parallel. Each prompt gives the target path, that
   batch's packages, and the [criteria](#criteria) below verbatim, since an
   auditor cannot read this skill. If the repo defines no such agent, start
   general-purpose read-only agents with the same brief: cognitive load by
   the criteria, readability, idiomatic use, conciseness, and YAGNI/KISS,
   findings ranked by impact with file and line.
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

## Criteria

Cognitive load is measured against working memory: a reader holds about 7
things at once (variables in scope, pending branches, collaborators). A
finding states the measured value.

- **Size.** A function fits an 80×24 box: at most 80 columns, 24 lines, one
  statement per line. Dense languages such as Haskell or F# want less.
  Cramming lines to fit is a finding, and so are helpers split off only to
  meet the count.
- **Cyclomatic complexity.** Count 1, plus 1 per `if`, loop, `case` arm and
  `&&`/`||`. Flag a function above about 7. A call to a well-named function
  adds nothing; that is complexity hidden where it belongs.
- **Thresholds are ratchets, not targets.** Use the repo's own limits when it
  has them. Report a unit over a limit as debt to pay back down, and code
  that games a limit as a finding of its own. Under every limit is not proof
  of clarity.
- **Acyclic dependencies.** Modules and packages form a graph without cycles:
  one back-edge fuses every component on the cycle into one. Report each
  cycle with its edges. Types sit below, functions over them above, entry
  points on top. Fix a cycle by moving the shared type down, passing a
  function or generic instead, or extracting the relationship into its own
  type, before adding an interface layer. A type-only or deferred import
  hides a cycle without removing it. Check at module grain, not between
  types inside one module.
- **Nesting.** Each enclosing branch, loop or closure is one more thing held
  in mind, and a closure that reads its parent's variables hides inputs.
  Propose replacing the nested block with one call to a pure function, which
  the reader can replace with its result.

## Common mistakes

- Starting auditors one per message, which runs them in sequence.
- Splitting by goal instead of by package: each auditor then loses the rule
  that a higher goal wins over a lower one.
- Passing reports through unmerged, so one pattern appears as N findings.
