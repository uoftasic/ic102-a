# Lab 02: Read the red X

Writeup: [uoftasic.com/ic102-a → Lab 02](https://uoftasic.com/ic102-a/labs/lab-02-read-the-red-x-overview.html)

`break.sh` puts one of five numbered mistakes into your repository from Lab 01. You commit it,
push it, and work out from the run on GitHub what went wrong before you fix it.

## Run it

In a workbench terminal, with a clean working tree in your repository:

```bash
cd /foss/designs/projects/ttsky-ic102-a
cp /foss/designs/modules/ic102-a/labs/lab-02-read-the-red-x/DIAGNOSIS.md .     # once
/foss/designs/modules/ic102-a/labs/lab-02-read-the-red-x/break.sh 1 .
```

| Breakage | What `break.sh` changes |
|---|---|
| 1 | `info.yaml`: every pinout description emptied |
| 2 | `layout/wires.tcl`: a stub of metal 4 on `ua[2]`, then `make` |
| 3 | `info.yaml`, `src/project.v` and the names of `gds/` and `lef/`: the top module renamed, with the layout not rebuilt |
| 4 | `layout/wires.tcl`: a 10 µm square of metal 5, then `make` |
| 5 | `info.yaml`: `uses_vapwr: true` |

The writeup doesn't say what each one does to the workflows, because you're meant to find that
out from the runs. `break.sh` won't run on a working tree with uncommitted changes, so that each breakage gets a
commit of its own.

## Files

| File | What it is |
|---|---|
| `break.sh` | applies one breakage |
| `DIAGNOSIS.md` | the template you copy into your repository and fill in |
