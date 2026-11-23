# Lab 03: A layout that passes precheck

Writeup: [uoftasic.com/ic102-a → Lab 03](https://uoftasic.com/ic102-a/labs/lab-03-a-layout-that-passes-precheck-overview.html)

You replace Lab 01's two stubs with an inverter wired to `ua[0]` and `ua[1]`, draw its output
wire yourself, and check the result with precheck and with LVS, which precheck doesn't do.

## Run it

From a workbench terminal, on a new branch in your repository:

```bash
/foss/designs/modules/ic102-a/labs/lab-03-a-layout-that-passes-precheck/start.sh /foss/designs/projects/ttsky-ic102-a
```

Then, from the top of your repository, `make`, `make drc`, `make lvs` and `make precheck`.

## What `start.sh` adds

| File in your repository | What it is |
|---|---|
| `layout/cells/ic102_inv.mag` | AD104 Lab 03's reference inverter (`solutions/inv_ref.mag` in [uoftasic/ad104](https://github.com/uoftasic/ad104), at b89a8b8), renamed; DRC and LVS clean |
| `layout/wires.tcl` | replaces Lab 01's stubs: the cell placed at (140, 10), its supplies and its input wired, and a TODO for the output wire |
| `layout/lvs/reference.spice` | the circuit the finished tile should contain, with your `top_module` filled in |

## Files here

| File | What it is |
|---|---|
| `start.sh` | copies the three files above into a repository |
| `cells/ic102_inv.mag` | the cell |
| `kit/wires.tcl`, `kit/reference.spice` | the other two, before `start.sh` fills in your top module |
| `solutions/wires.tcl` | the finished `wires.tcl`. Open it after yours passes, or when you're stuck |
