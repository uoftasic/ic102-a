# `labs/common/tt-tools`: Tiny Tapeout's precheck in the workbench

When you push to a repository made from Tiny Tapeout's analog template, the gds workflow runs Tiny Tapeout's precheck on your layout. Precheck doesn't use the tools in your workbench. It installs its own: Magic 8.3.568, KLayout 0.30.8 and the sky130A PDK at open_pdks commit `0536d02d`, where the workbench image has Magic 8.3.681, KLayout 0.30.11 and sky130A at `026824c7`. This folder installs precheck's versions next to the workbench's, without changing the image, and runs the same precheck on your repository, so you can read the runner's verdict before you push. IC102-A pins these versions on purpose; the other courses keep the workbench's.

The writeups that use it are [Lab 02](https://uoftasic.com/ic102-a/labs/lab-02-read-the-red-x-overview.html) and [Lab 03](https://uoftasic.com/ic102-a/labs/lab-03-a-layout-that-passes-precheck-overview.html), and [Your tools and the runner's tools](https://uoftasic.com/ic102-a/guide/your-tools-and-the-runners-tools.html) explains why the versions differ.

## Install

Everything here runs in a terminal on the workbench desktop. If you haven't set up the workbench, do [IC101 Lab 03](https://uoftasic.com/ic101/labs/lab-03-launch-the-workbench-overview.html) first.

```bash
. /foss/designs/common/.designinit
mod add ic102-a                  # first time only
mod ic102-a
cd labs/common/tt-tools
make install
```

`make install` took 85 s on one CPU core with a fast connection: 43 s of that is compiling Magic, and 26 s is downloading and unpacking the PDK. It leaves 1.8 GB in `.local/`, which is on your own disk (the workspace folder is mounted at `/foss/designs`), so it survives a container restart and you install once. The parts are Python 3.11 with precheck's packages (`venv/`, 371 MB, plus 90 MB for the interpreter in `python/`), the PDK (`pdk/`, 1.1 GB), KLayout (225 MB), Magic (12 MB) and Tiny Tapeout's `tt-support-tools` (9.4 MB), which holds precheck itself. If a download fails partway, run `make install` again: it skips the parts that finished.

Then check what you got:

```bash
make check-tools
```

You should see:

```
Tool               Runner (pinned)      Here                 Workbench            Status
----               ---------------      ----                 ---------            ------
Python             3.11.18              3.11.16              3.12.3               ok (3.11)
Magic              8.3.568              8.3.568              8.3.681              ok
KLayout            0.30.8               0.30.8               0.30.11              ok
klayout (pip)      0.30.13              0.30.13              0.30.11              ok
gdstk (pip)        0.9.52               0.9.52               1.0.1                ok
yowasp-yosys       0.63.0.0.post1107    0.63.0.0.post1107    -                    ok
ciel               3.2.0                3.2.0                2.6.1                ok
sky130A PDK        0536d02d875c         0536d02d875c         026824c7969c         ok
tt-support-tools   9d13ff3e3e62         9d13ff3e3e62         -                    ok

All pinned tools are installed at the runner's versions.
```

The "Runner" column is what Tiny Tapeout's precheck job used when we read it on Nov 15 and 16, 2026, "Here" is what `make install` put in `.local/`, and "Workbench" is what the image has. Python matches on 3.11 rather than on the last digit, because the `uv` in the image offers nothing newer than 3.11.16; the packages are built for 3.11 either way.

To see the whole chain work, run precheck on the smallest layout that should pass, the analog template's empty 1x2 frame drawn by Tiny Tapeout's own `magic_init_project.tcl`, with a short metal stub on `ua[0]` and `ua[1]`:

```bash
make selftest
```

It ends with `INFO: Precheck passed for .../tt_um_ic102_selftest.gds! 🎉` and the table of 15 checks, all ✅. The first run takes about 47 s, because precheck's Verilog check runs Yosys compiled to WebAssembly (`yowasp-yosys`), which compiles itself the first time; later runs take 12 to 15 s.

## Running precheck on your repository

Point `PROJECT` at the top folder of your repository, the one with `info.yaml` in it:

```bash
make precheck PROJECT=/foss/designs/your-repository
```

The script does what the two jobs on GitHub do. First it copies `gds/<top_module>.gds`, `lef/<top_module>.lef` and `src/project.v` into `tt_submission/`, as the custom_gds step does before it uploads that folder. Then it runs `precheck.py` from `tt-support-tools`, with `PDK_ROOT` pointing at the pinned PDK and nothing from the workbench on the `PATH`. It prints the tool versions it used, precheck's own log, and the results table the runner puts in the job summary. Here is the end of a real run on a public project whose layout had a Magic DRC error, `alokerdas/ttsky26d_analog_LnL_ringosc` at 8181333, which failed precheck on GitHub with the same two errors (run 42980657883), cloned to `/foss/designs/ttsky26d_analog_LnL_ringosc`:

```
[ERROR]: 2 DRC errors found
...
ERROR: Precheck failed for /foss/designs/ttsky26d_analog_LnL_ringosc/tt_submission/tt_um_LnL_ringosc.gds! 😭
ERROR: See /foss/designs/modules/ic102-a/labs/common/tt-tools/.local/tt-support-tools/precheck/reports for more details
ERROR: Markdown report:
# Tiny Tapeout Precheck Results

| Check | Result |
|-----------|--------|
| Magic DRC | ❌ Fail: Magic DRC failed |
| KLayout FEOL | ✅ |
...
| Verilog syntax check | ✅ |

In case of failure, please reach out on [discord](https://tinytapeout.com/discord) for assistance.


Reports: /foss/designs/ttsky26d_analog_LnL_ringosc/tt_submission/precheck_reports/
make: *** [Makefile:30: precheck] Error 1
```

Precheck names its own reports folder inside `.local/`; the script copies it into your repository afterwards, to the path on the `Reports:` line, which holds the same files the runner uploads as the `precheck_reports` artifact. For a Magic error, `magic_drc.txt` names the rule and the coordinates (here `met2.3a`, at `131.790 45.470 132.020 45.750` and one more box), and `magic_drc.mag` is your cell with the errors marked, which you can open in Magic. The KLayout checks write `drc_*.xml`, which KLayout's marker browser reads. The last line is `make` passing on precheck's failure, not a second error. `tt_submission/` is already in the template's `.gitignore`, so none of this ends up in a commit.

To run the same checks with the workbench's own Magic, KLayout and PDK, for comparison:

```bash
make precheck-workbench PROJECT=/foss/designs/your-repository
```

## Comparison with the runner

We ran `make precheck` on 11 commits of 6 public analog projects whose precheck runs on GitHub were still readable, 6 that failed precheck and 5 that passed. The failures cover six of the 15 checks: Magic DRC, KLayout FEOL (1,740 violations on one layout), pin labels, the pin check, the power pin check and the analog pin check. On all 11, the table matched the runner's row for row, including the text of every failure. For two of the failing runs we could also download the runner's `precheck_reports` artifact: the Magic report was the same file, byte for byte, and the KLayout reports listed the same 1,740 and 2 markers at the same coordinates. On the layout with 1,740 FEOL violations, the intermediate counts that KLayout prints as it works through the deck (1,074 lines of them) were identical to the runner's log.

The workbench's own tools gave the same 11 tables, so on these layouts the newer versions reach the same verdicts. They don't take the same path, though. On the FEOL layout, the `enclosing` check at line 1047 of the deck (`sky130A_mr.drc`, the li-over-licon enclosure) found 7,089 edge pairs with KLayout 0.30.11, where 0.30.8 and the runner found 7,053, and the one at line 1195 (metal 1 over mcon) found 1,303 where they found 1,258. Both versions still ended at 1,740 violations. Only one of the 11 layouts had a Magic DRC error, which is too few to say that Magic 8.3.681 always agrees with 8.3.568. That is why precheck with the pinned tools, and not the workbench's DRC, is the course's check.

## Differences from the runner

| Difference | Why it doesn't change precheck's result |
|---|---|
| Python 3.11.16 here, 3.11.18 on the runner | Every package is the same version, built for 3.11. |
| Magic is compiled here from its 8.3.568 tag; the runner gets the nixpkgs build of the same tag | Nixpkgs builds it with no patches. Ours has no OpenGL or Cairo display (the image has no headers for them), and so `install.sh` deletes the 25 key bindings for the 3D window from Magic's startup file, because 8.3.568 crashes on them without OpenGL. Neither touches DRC, and the Magic reports matched on all 11 layouts. |
| KLayout 0.30.8 comes from klayout.org's Ubuntu 24.04 package, plus five Qt 5 libraries from Ubuntu, instead of nixpkgs | Same release; the per-rule counts matched the runner's line for line. |
| The pip `klayout` module is pinned at 0.30.13 | Precheck allows any 0.30.x, so the runner takes the newest on the day: 0.30.12 on Nov 2, 0.30.13 on Nov 15. |
| `tt-support-tools` is pinned at 9d13ff3 | The runner checks out `main` on every run. Precheck's code last changed on Oct 29, 2026. |
| `sky130B` is deleted after the PDK is unpacked | Precheck reads only `sky130A`; this saves 1.1 GB. |
| The `.oas` copy and the PNG render that custom_gds makes with KLayout 0.29.12 are left out | Precheck reads only the `.gds`. |
| The docs job isn't reproduced | It checks `info.yaml` and `docs/info.md`, not the layout. |

## Troubleshooting

| If you see | Do this |
|---|---|
| `The read operation timed out` while the PDK downloads | The download server didn't answer in time; precheck on GitHub has failed the same way (erik1567/ttsky26d-VCO, run 42570954316). Run `make install` again. It resumes at the part that failed. |
| `make: *** [Makefile:30: precheck] Error 1` after the table, or, when you ran `make precheck` from your repository, `make[1]: *** [Makefile:30: precheck] Error 1` and then `make: *** [Makefile:104: precheck] Error 2` | That is precheck's failure passed on by `make`: once by this folder's Makefile, and once more by your repository's, which runs it. Read the ❌ rows in the table above it. |
| `Segmentation fault` in a log under `.local/selftest/` | The workbench's Magic 8.3.681 sometimes crashes as it exits in batch mode, after it has written its files. `make selftest` checks the files instead of the exit status, so the crash doesn't fail the test. |

## Targets

| Target | What it does | Time (one core) |
|---|---|---|
| `make install` | Install the pinned tools into `.local/` | 85 s |
| `make check-tools` | Print each version next to the pin and the workbench's | instant |
| `make selftest` | Precheck on the analog template's empty 1x2 frame | 47 s first time, then 12 to 15 s |
| `make precheck PROJECT=<dir>` | Precheck on your repository, with the pinned tools | 11 to 30 s for a 1x2 or 2x2 layout, about 60 s for a 10 MB 3x2 layout |
| `make precheck-workbench PROJECT=<dir>` | The same checks with the workbench's Magic, KLayout and PDK | about the same |
| `make uninstall` | Delete `.local/` | |

## Files

| File | What it is |
|---|---|
| `pins.env` | Every pinned version, with the run or file it was read from. The other scripts read it, so a version changes in one place. |
| `requirements.txt` | The precheck job's Python packages, copied from its pip log, with every dependency pinned |
| `klayout-qt-libs.txt` | The five Qt 5 packages KLayout 0.30.8 needs and the image lacks, with checksums |
| `install.sh` | The installer; `./install.sh magic` redoes one part |
| `check-tools.sh` | `make check-tools` |
| `precheck.sh` | `make precheck`; `TT_TOOLSET=workbench` selects the workbench's tools |
| `selftest.sh` | `make selftest` |

When Tiny Tapeout moves the `ttsky26d` tag, or the template moves to a new tag, the versions in `pins.env` have to be read again from the new action files and a new runner log. The steps are at the top of `pins.env`.
