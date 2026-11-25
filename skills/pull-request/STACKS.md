# Stacked PRs

A stack is a chain of PRs, each based on the branch below it. Every layer stays one concern
within the budget in [`SKILL.md`](SKILL.md) "Open a PR", and reviewers read them in order. The
commands for each step are in the platform file ([`GITHUB.md`](GITHUB.md) or
[`GITLAB.md`](GITLAB.md)).

## Size a stack

Fewer, fuller layers review faster: each layer adds a wait between approval and merge. Count the
whole change as in SKILL.md "Open a PR", over `origin/<default branch>...<top branch>`, and pick
the stack by its size; the line count decides the tier:

- **Focused** (up to about 600 changed lines, usually one capability): 1 to 3 layers. Grow a
  layer up to the 300-line ceiling to stay within 3. Split for a concern, never just to add a
  layer.
- **Large** (about 600 to 1,500 lines): up to 5 layers. Grow layers toward 300 before you add
  another.
- **Too big** (it cannot fit in 5 layers of at most 300 lines plus their own tests): the work was
  cut too big. Split it into smaller pieces, in this order, and take the first that fits:
  1. Pieces that do not depend on each other go out as separate PRs or stacks against the
     default branch.
  2. Dependent pieces go out as sequential stacks: land the foundation stack first, then start
     the next stack from the default branch.
  3. A stack past 5 layers needs a very good reason: a strict dependency chain where every seam
     is a natural boundary and every non-bulk layer is at the ceiling. State the reason to the
     owner and wait for their OK before you build it, then name the reason in the bottom PR's
     body.

Slice by dependency: each layer builds and passes the checks on its own. Cut layers only at
**natural boundaries**, and merge neighbouring layers across any other line:

- a refactor or preparation step before the feature
- mechanical bulk (moves, copies, generated files), in a layer of its own
- a new module or package and its public interface
- the implementation behind that interface
- a schema, data or config migration
- the wiring or switch that turns the feature on, at the top

Tests stay in the layer with the code they cover. A mechanical-bulk layer counts as a layer, and
its lines are exempt from the budget as in SKILL.md. Done when the stack fits its size, every
seam is one of these boundaries, and each layer builds and passes the checks on its own.

## Build a stack

Build with the platform file's stack commands. When the repo's PR doc asks for a line naming the
PR below, add it in the format the doc sets.

Outside `gh stack`, after changing a lower layer, merge it into each branch above, bottom up, and
push: no force-push, so no owner approval. Rebase instead only when the owner wants a linear
history (or in a `gh stack` stack; see `GITHUB.md`). A rebase rewrites branches you already
pushed, so the next push is a force-push: ask the owner before it. Some agent harnesses block
force-push; then report the commands and let the owner run them.

Done when every layer has an open PR whose base is the branch below it (the bottom one's is the
default branch), with its title and body written by SKILL.md "Open a PR".

## Merge a stack

A linked GitHub stack uses the one command in [`GITHUB.md`](GITHUB.md) "Merge a stack". The
steps below are for a stack the platform has not linked.

Merge from the bottom up, by the platform file's procedure for the repo's merge method. When the
platform refuses a merge (failing checks, a missing review, a ruleset), report its message. Apart
from a fallback the platform file names, do not retry through another endpoint. Done when the
platform shows each PR as merged.

## Review a stack

Review each PR on its own. A reviewer of one layer, such as a session or subagent given one PR,
pushes fixes only to that PR's branch and leaves merging and new PRs to whoever owns the stack.
Its last reply lists each finding with what it did about it. The stack's owner then merges each
changed branch into the ones above it, bottom up, before the stack lands.
One check suite runs on the machine at a time.
A timeout in a test the change does not touch, while another worktree is running the suite, means run that suite again.
Before the stack merges, review it once as a whole, for problems between PRs only. The range runs
from the merge base with the default branch to the top branch. Leave vendored files out with
`':!<path>'` pathspecs:

```sh
git diff $(git merge-base origin/<default branch> <top>)..<top>
```

Done when every problem the whole-range diff raises is fixed in the layer it belongs to and
merged into the layers above it, and the repo's check command is green on the top branch,
including a test that still expects the previous layer's stub.
