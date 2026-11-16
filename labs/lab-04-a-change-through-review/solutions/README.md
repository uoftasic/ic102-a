# Lab 04, Part 7: what's wrong with the AI-written pull request

`ai-pr/ai-pr.sh` writes the pull request onto the lowest free slot K whose neighbour K+1 is also
free, on the partner's `main`. The writeup gives the same answers in a collapsed block, under
Part 7. Outputs below are from a rehearsal where K was 0, and the live test of Nov 16, 2026
(vproHacks/ic102-review-sandbox-a#3, K also 0) gave the same ones, with every check on GitHub
green.

| Where | Problem | How a reviewer finds it |
|---|---|---|
| `gds/`, `lef/` | Not rebuilt: the pull request changes `slots.tcl` and adds a cell, but commits the old GDS and LEF, so every check runs on `main`'s layout and passes | The file list has four files and no `gds/`; the `gds_render` PNG has no new inverter; `make lvs` on the branch warns `layout/slots.tcl layout/cells/inv_ai.mag changed after gds/tt_um_ic102a_sandbox.gds was written` and ends `Final result: Top level cell failed pin matching.` |
| `info.yaml` | The pinout describes `ui[K+1]` and `uo[K+1]` for an inverter in slot K | The text diff; neither precheck nor LVS reads the descriptions (after `make`, `make lvs` matches with the wrong pinout still in place) |
| `.gitignore` | Adds `gds/` and `lef/` as "build output", a change the claim didn't need that contradicts the analog template, whose `gds` workflow reads both from the repository | The text diff, and [Layout files in git](https://uoftasic.com/ic102-a/guide/layout-files-in-git.html) |
| The description | Claims `make lvs` printed `Circuits match uniquely.` for this commit, which it can't have | Running `make lvs` on the branch |

The description's precheck claim is true: `make precheck` passes 15/15 on this branch, because the
GDS is the one `main` already had. The `docs` check passes too.
