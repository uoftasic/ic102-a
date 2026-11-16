![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg)

# IC102-A cohort sandbox

A shared analog Tiny Tapeout project for one cohort of [IC102-A](https://uoftasic.com/ic102-a/),
used in [Lab 04: A change through review](https://uoftasic.com/ic102-a/labs/lab-04-a-change-through-review-overview.html).
It is a practice repository and is never submitted to a shuttle.

The tile starts with one inverter, the anchor, between `ua[0]` and `ua[1]`. It has eight empty
slots, and each student in the cohort fills one of them with an inverter of their own, through a
pull request that someone else in the cohort reviews. Slot K takes its input from `ui_in[K]` and
drives `uo_out[K]`, which is why there are eight: a 1x2 tile has eight `ui_in` and eight
`uo_out` pins, and only six usable analog pins.

## Claiming a slot

Your pull request changes four things, and the lab writeup goes through each one:

1. `layout/cells/inv_<you>.mag`, a copy of your inverter from Lab 03, where `<you>` is your GitHub
   username with any `-` changed to `_`.
2. One line in `layout/slots.tcl`, `slot K inv_<you>`, in slot order.
3. The `ui[K]` and `uo[K]` lines of the pinout in `info.yaml`.
4. `gds/` and `lef/`, rebuilt with `make` from the three files above.

Before you push, run `make precheck` and `make lvs` in the IC102-A workbench and paste their last
lines into the pull request's description.

## Conflicts in gds/ and lef/

Every pull request here changes `gds/tt_um_uoftasic_ic102a_sandbox.gds`, so after anyone's pull
request is merged, everyone else's conflicts with `main`. Git can't merge a GDS file, because it's
binary, and a LEF file that git has merged line by line describes no real layout, so don't try to
resolve either by hand. Resolve the text files (`layout/slots.tcl`, `info.yaml`) by hand, keeping
both sides' claims, then run `make` to build `gds/` and `lef/` again from the merged sources, and
commit the result. GitHub doesn't run a pull request's workflows while it has a conflict, so your
checks start again once you push the merge.

## Rules for main

`main` takes changes only through a pull request with one approval from someone other than its
author, and with the `docs`, `gds` and `precheck` checks green. [RULESET.md](RULESET.md) lists the
ruleset in full. [REVIEWING.md](REVIEWING.md) is the checklist for reviewers.

## Building

In the IC102-A workbench, from the top of this repository:

| Command | What it does |
|---|---|
| `make` | build `gds/` and `lef/` from `layout/` |
| `make precheck` | Tiny Tapeout's precheck, with the runner's versions of its tools |
| `make lvs` | the layout against a reference written from `layout/slots.tcl` |
| `make drc` | Magic DRC with the workbench's Magic, to compare with precheck's |
| `make docs` | the docs workflow's check of `info.yaml` and `docs/info.md` |
| `make view` | open the layout in Magic |

The checks come from the course repository, cloned with `mod add ic102-a`.
[layout/UPSTREAM.md](layout/UPSTREAM.md) says where the copied files in `layout/` came from.
