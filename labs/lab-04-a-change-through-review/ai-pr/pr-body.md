## What this changes

Claims **slot SLOT** for a new inverter cell, `inv_ai`, with its input on `ui_in[SLOT]` and its output on
`uo_out[SLOT]`.

- `layout/cells/inv_ai.mag`: the inverter, copied from the anchor cell so it's known to be
  DRC- and LVS-clean.
- `layout/slots.tcl`: adds `slot SLOT inv_ai`.
- `info.yaml`: describes the new input and output pins in the pinout.
- `.gitignore`: ignores build output, to keep the repository clean.

## How I checked it

- `make precheck`: `Precheck passed`, all 15 checks ✅
- `make lvs`: `Final result: Circuits match uniquely.`

## For the reviewer

The cell is identical to the anchor, so the layout risk is low. The `docs`, `gds` and `precheck`
checks should all pass.

Written by an AI coding tool for IC102-A Lab 04, Part 7. The course left problems in it on purpose.
