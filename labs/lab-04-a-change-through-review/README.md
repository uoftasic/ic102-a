# Lab 04: A change through review

Writeup: [uoftasic.com/ic102-a → Lab 04](https://uoftasic.com/ic102-a/labs/lab-04-a-change-through-review-overview.html)

Each student copies `sandbox/` into a new public repository in their own account,
`ttsky-ic102-a-review`, and their partner changes it through a pull request from a fork,
`ttsky-ic102-a-review-fork`. The writeup has the steps. Both repositories are in the students'
own accounts, so the lab uses no organization repository, and nobody has to create anything for
the students beforehand.

## Checking the sandbox locally

From `sandbox/` (or a copy of it), in the workbench, with the course tools installed:

| Command | What it does |
|---|---|
| `make` | build `gds/` and `lef/` from `layout/` |
| `make precheck` | Tiny Tapeout's precheck with the pinned tools: all 15 checks pass on the empty sandbox |
| `make lvs` | LVS against the reference that `layout/lvs/reference.py` writes from `layout/slots.tcl` |
| `make docs` | the `docs` workflow's check of `info.yaml` and `docs/info.md` |

## Files

| Path | What it is |
|---|---|
| `sandbox/README.md` | the review repository's README: claiming a slot, and conflicts in `gds/` |
| `sandbox/REVIEWING.md` | the reviewers' checklist |
| `sandbox/RULESET.md`, `sandbox/ruleset.json` | the ruleset for `main`, to import under Settings › Rules › Rulesets, and the two settings that go with it |
| `sandbox/.github/workflows/` | the analog template's `gds` and `docs` workflows, triggered on pull requests and on pushes to `main`, with `viewer` skipped on pull requests |
| `sandbox/.github/pull_request_template.md` | what a pull request's description asks for |
| `sandbox/layout/wires.tcl` | the anchor inverter, the `slot` command and the tie-offs |
| `sandbox/layout/slots.tcl` | who holds which slot; empty to start with |
| `sandbox/layout/lvs/reference.py` | writes the LVS reference from `slots.tcl` |
| `sandbox/Makefile`, `sandbox/layout/*.tcl` | Lab 01's layout kit |
| `sandbox/gds/`, `sandbox/lef/` | the empty sandbox's layout, built with `make` |
| `ai-pr/ai-pr.sh`, `ai-pr/pr-body.md` | Part 7 (optional): an AI-written pull request with planted problems, put on a branch of the student's fork |
| `solutions/README.md` | the problems in that pull request, and the outputs that show them |
