# Lab 04: A change through review

Writeup: [uoftasic.com/ic102-a → Lab 04](https://uoftasic.com/ic102-a/labs/lab-04-a-change-through-review-overview.html)

Lab 04 happens in a repository the whole cohort shares, a small analog Tiny Tapeout project with
eight slots. Each student claims a slot through a pull request, reviews a classmate's, and merges
`main` into their own branch at least once. This folder holds that repository's contents, ready to
be pushed, in `sandbox/`.

## Making a cohort's sandbox

One sandbox takes up to eight students, one per slot. A TA or the course lead makes it before the
lab:

1. Create an empty public repository in the `uoftasic` organization, for example
   `ic102a-sandbox-2027w`.
2. Push the contents of `sandbox/` to it as its first commit, from a workbench terminal:

   ```bash
   cp -r /foss/designs/modules/ic102-a/labs/lab-04-a-change-through-review/sandbox ic102a-sandbox
   cd ic102a-sandbox
   git init -b main && git add -A && git commit -m "IC102-A cohort sandbox"
   git remote add origin https://github.com/uoftasic/<name>.git
   git push -u origin main
   ```

3. Settings › Pages › Build and deployment › Source: GitHub Actions.
4. Set up the ruleset and the fork approval setting in
   [sandbox/RULESET.md](sandbox/RULESET.md) (New ruleset › Import a ruleset reads
   [sandbox/ruleset.json](sandbox/ruleset.json)).
5. Wait for the first `gds` and `docs` runs on `main` to go green, `viewer` included, and post the
   repository's link in the cohort's channel.

The writeup tells students to fork the repository, so nobody needs to be added to it. If a cohort
is larger than eight, make one sandbox per eight students.

## Checking the sandbox locally

From `sandbox/`, in the workbench, with the course tools installed:

| Command | What it does |
|---|---|
| `make` | build `gds/` and `lef/` from `layout/` |
| `make precheck` | Tiny Tapeout's precheck with the pinned tools: all 15 checks pass on the empty sandbox |
| `make lvs` | LVS against the reference that `layout/lvs/reference.py` writes from `layout/slots.tcl` |

## Files

| Path | What it is |
|---|---|
| `sandbox/README.md` | the cohort repository's README: how to claim a slot, and conflicts in `gds/` |
| `sandbox/REVIEWING.md` | the reviewers' checklist |
| `sandbox/RULESET.md`, `sandbox/ruleset.json` | the ruleset for `main` and the two settings that go with it |
| `sandbox/.github/workflows/` | the analog template's `gds` and `docs` workflows, triggered on pull requests and on pushes to `main`, with `viewer` skipped on pull requests |
| `sandbox/.github/pull_request_template.md` | what a pull request's description asks for |
| `sandbox/layout/wires.tcl` | the anchor inverter, the `slot` command and the tie-offs |
| `sandbox/layout/slots.tcl` | who holds which slot; empty to start with |
| `sandbox/layout/lvs/reference.py` | writes the LVS reference from `slots.tcl` |
| `sandbox/Makefile`, `sandbox/layout/*.tcl` | Lab 01's layout kit |
| `sandbox/gds/`, `sandbox/lef/` | the empty sandbox's layout, built with `make` |
