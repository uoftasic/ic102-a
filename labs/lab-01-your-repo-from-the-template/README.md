# Lab 01: Your repository from the template

Writeup: [uoftasic.com/ic102-a → Lab 01](https://uoftasic.com/ic102-a/labs/lab-01-your-repo-from-the-template-overview.html)

You make your own repository from Tiny Tapeout's analog template, fill it in, and commit a
placeholder layout, the template's empty 1x2 frame drawn by Tiny Tapeout's own script, until every
workflow passes. `start.sh` adds the course's layout kit to your repository.

## Run it

Install the course tools first ([`labs/common/tt-tools`](../common/tt-tools/README.md)), then, in a
workbench terminal:

```bash
/foss/designs/modules/ic102-a/labs/lab-01-your-repo-from-the-template/start.sh /foss/designs/projects/ttsky-ic102-a
```

It copies the kit and never overwrites a file that exists.

## What the kit puts in your repository

| File | What it is |
|---|---|
| `Makefile` | `make`, `make docs`, `make precheck`, `make drc`, `make lvs`, `make view`, `make clean` |
| `layout/init.tcl` | Tiny Tapeout's `magic_init_project.tcl`, unchanged until you edit its settings block |
| `layout/tt_analog_1x2.def` | Tiny Tapeout's 1x2 analog DEF template |
| `layout/UPSTREAM.md` | where those two came from, with the commit |
| `layout/wires.tcl` | what the layout adds to the frame: two stubs of metal 4, on `ua[0]` and `ua[1]` |
| `layout/build.tcl`, `layout/drc.tcl`, `layout/extract.tcl` | the scripts behind `make`, `make drc` and `make lvs` |
| `layout/README.md` | which of these files you edit |

`make` builds the layout with precheck's own Magic and PDK from `labs/common/tt-tools/.local`;
`make drc` and `make view` use the workbench's.

## Files here

| File | What it is |
|---|---|
| `start.sh` | copies the kit into a repository |
| `kit/` | the kit's files |
