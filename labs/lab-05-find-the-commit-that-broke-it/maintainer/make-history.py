#!/usr/bin/env python3
"""Build Lab 05's prepared history, labs/lab-05-find-the-commit-that-broke-it/history.bundle.

For maintainers, not students. Run it in the course image, in the workbench folder layout, with
the course tools installed (`make -C labs/common/tt-tools install`):

    python3 maintainer/make-history.py /tmp/lab05-build history.bundle

It makes a small analog Tiny Tapeout project, tt_um_ic102_lab05, commit by commit: the analog
template, Lab 01's layout kit, Lab 03's inverter, then a few weeks of the kind of changes a project
gets. Every commit that changes the layout runs `make` with the Lab 01 kit, so each GDS really is
what that commit's sources build. One commit (number 18, "Widen Y's wire to ua[1]") brings the two
metal2 wires 0.10 um apart, under the 0.14 um minimum, and Magic DRC fails from there on. Two
commits can't be tested: number 13 has a GDS that Magic's crash cut short, and number 20 has no
gds/ folder at all.

The result is reproducible: authors, dates and the tag are fixed, and the build time that Magic
writes into each GDS is replaced with the commit's date (BGNLIB and BGNSTR records), so running
this again gives the same commit hashes. Precheck doesn't read those dates. If you change a step,
the hashes from that commit on change, and the writeup's expected outputs must be re-run.
"""
import os
import shutil
import struct
import subprocess
import sys
from pathlib import Path

TEMPLATE = "https://github.com/TinyTapeout/ttsky-analog-template"
TEMPLATE_COMMIT = "301590bc02ffeabc2bb176489de9db0818a4b958"
TOP = "tt_um_ic102_lab05"
COURSE = Path(__file__).resolve().parents[3]          # the ic102-a checkout
KIT = COURSE / "labs/lab-01-your-repo-from-the-template"
LAB03 = COURSE / "labs/lab-03-a-layout-that-passes-precheck"

AVERY = ("Avery Example", "avery@example.com")
SAM = ("Sam Example", "sam@example.com")


def run(cmd, cwd, env=None, check=True):
    r = subprocess.run(cmd, cwd=cwd, env=env, text=True, capture_output=True)
    if check and r.returncode != 0:
        sys.exit(f"failed: {' '.join(cmd)}\n{r.stdout}\n{r.stderr}")
    return r


def edit(repo, path, old, new, count=1):
    p = repo / path
    s = p.read_text()
    if s.count(old) != count:
        sys.exit(f"{path}: expected {count} of {old!r}, found {s.count(old)}")
    p.write_text(s.replace(old, new))


def append(repo, path, text):
    with open(repo / path, "a") as f:
        f.write(text)


def set_gds_dates(gds, when):
    """Overwrite the modification and access dates Magic writes into BGNLIB/BGNSTR records."""
    data = bytearray(gds.read_bytes())
    date = struct.pack(">6H", when[0] - 1900, when[1], when[2], when[3], when[4], when[5])
    i = 0
    while i + 4 <= len(data):
        length, rtype = struct.unpack(">HH", data[i:i + 4])
        if length < 4:
            break
        if rtype in (0x0102, 0x0502):                 # BGNLIB, BGNSTR: two 12-byte dates
            data[i + 4:i + 16] = date
            data[i + 16:i + 28] = date
        i += length
    gds.write_bytes(bytes(data))


def build(repo, when):
    r = run(["make", "--no-print-directory", f"IC102={COURSE}"], repo, check=False)
    if r.returncode != 0:
        sys.exit(f"make failed:\n{r.stdout}\n{r.stderr}")
    set_gds_dates(repo / f"gds/{TOP}.gds", when)


def commit(repo, n, who, msg, day, hour, minute):
    stamp = f"2026-10-{day:02d}T{hour:02d}:{minute:02d}:00-04:00"
    env = dict(os.environ,
               GIT_AUTHOR_NAME=who[0], GIT_AUTHOR_EMAIL=who[1], GIT_AUTHOR_DATE=stamp,
               GIT_COMMITTER_NAME=who[0], GIT_COMMITTER_EMAIL=who[1], GIT_COMMITTER_DATE=stamp)
    run(["git", "add", "-A"], repo)
    run(["git", "commit", "-q", "-m", msg], repo, env=env)
    print(f"{n:2d} {run(['git', 'rev-parse', '--short', 'HEAD'], repo).stdout.strip()} {msg.splitlines()[0]}")


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: make-history.py WORKDIR OUT.bundle")
    work = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[2]).resolve()
    if work.exists():
        shutil.rmtree(work)
    work.mkdir(parents=True)
    repo = work / "ttsky-ic102-lab05"

    # The template, as "Use this template" would give it: its files in one new commit.
    tmpl = work / "template"
    run(["git", "init", "-q", str(tmpl)], work)
    run(["git", "fetch", "-q", "--depth", "1", TEMPLATE, TEMPLATE_COMMIT], tmpl)
    run(["git", "checkout", "-q", "FETCH_HEAD"], tmpl)
    shutil.copytree(tmpl, repo, ignore=shutil.ignore_patterns(".git"))
    run(["git", "init", "-q", "-b", "main"], repo)

    c = 0

    def step(who, msg, day, hour, minute, layout=False):
        nonlocal c
        c += 1
        if layout:
            build(repo, (2026, 10, day, hour, minute, 0))
        commit(repo, c, who, msg, day, hour, minute)

    step(AVERY, "Initial commit", 1, 19, 2)

    edit(repo, "info.yaml", 'title:        ""', 'title:        "Inverter between two analog pins"')
    edit(repo, "info.yaml", 'author:       ""', 'author:       "Avery Example, Sam Example"')
    edit(repo, "info.yaml", 'description:  ""', 'description:  "A CMOS inverter from AD104, wired to ua[0] and ua[1]"')
    edit(repo, "info.yaml", 'top_module:  "tt_um_example"', f'top_module:  "{TOP}"')
    edit(repo, "info.yaml", 'ua[0]: ""', 'ua[0]: "in (stub)"')
    edit(repo, "info.yaml", 'ua[1]: ""', 'ua[1]: "out (stub)"')
    step(AVERY, "Fill in info.yaml", 1, 19, 20)

    edit(repo, "docs/info.md", "Explain how your project works",
         "A single CMOS inverter: ua[0] is its input and ua[1] its output.")
    edit(repo, "docs/info.md", "Explain how to use your project",
         "Drive ua[0] from 0 V to 1.8 V and watch ua[1] fall from 1.8 V to 0 V.")
    step(AVERY, "Describe the project in docs/info.md", 1, 19, 41)

    edit(repo, "src/project.v", "module tt_um_example", f"module {TOP}")
    step(AVERY, "Rename the module in src/project.v to match top_module", 1, 19, 44)

    run([str(KIT / "start.sh"), str(repo)], work)
    edit(repo, "layout/init.tcl", "set TOP_LEVEL_CELL     tt_um_analog_example", f"set TOP_LEVEL_CELL     {TOP}")
    step(AVERY, "Add the IC102-A layout kit: the 1x2 frame and stubs on ua[0] and ua[1]", 1, 20, 15,
         layout=True)

    edit(repo, "README.md", "# Tiny Tapeout Analog Project Template",
         "# An inverter between two analog pins\n\nA practice project made from Tiny Tapeout's analog template.")
    step(SAM, "README: say what this project is", 3, 18, 5)

    run([str(LAB03 / "start.sh"), str(repo)], work)
    shutil.copy(LAB03 / "solutions/wires.tcl", repo / "layout/wires.tcl")
    edit(repo, "layout/init.tcl", "    VDPWR 1um", "    VDPWR 146um")
    edit(repo, "layout/init.tcl", "    VGND  4um", "    VGND  136um")
    edit(repo, "info.yaml", 'ua[0]: "in (stub)"', 'ua[0]: "inverter input"')
    edit(repo, "info.yaml", 'ua[1]: "out (stub)"', 'ua[1]: "inverter output"')
    step(SAM, "Place the inverter and wire it to ua[0] and ua[1]\n\n"
         "Precheck passes on this commit, and make lvs reports that the circuits match.",
         3, 21, 30, layout=True)
    env = dict(os.environ, GIT_COMMITTER_NAME=SAM[0], GIT_COMMITTER_EMAIL=SAM[1],
               GIT_COMMITTER_DATE="2026-10-03T21:31:00-04:00")
    run(["git", "tag", "-a", "v0.1", "-m", "First layout that passes precheck and LVS"], repo, env=env)

    append(repo, "docs/info.md", "\n## Pins\n\nua[0] is the input and ua[1] the output. "
           "Every digital output is tied to ground.\n")
    step(AVERY, "docs: list the pins", 4, 10, 12)

    edit(repo, "layout/wires.tcl", "p metal1 136.4  9.6 137.6 10.8      ;# landing pad under the VGND stripe",
         "p metal1 136.2  9.4 137.8 11.0      ;# landing pad under the VGND stripe")
    edit(repo, "layout/wires.tcl", "p metal2 136.4  9.6 137.6 10.8\np metal3 136.4  9.6 137.6 10.8",
         "p metal2 136.2  9.4 137.8 11.0\np metal3 136.2  9.4 137.8 11.0")
    step(SAM, "Widen the VGND landing pad to 1.6 um", 5, 20, 2, layout=True)

    append(repo, "README.md", "\n## Building the layout\n\nIn the IC102-A workbench, run `make`, "
           "then `make precheck` and `make lvs`.\n")
    step(SAM, "README: how to build the layout", 5, 20, 40)

    append(repo, "docs/info.md", "\nA 1 kHz square wave on ua[0] is enough to see the inversion on "
           "an oscilloscope.\n")
    step(SAM, "docs: what to drive ua[0] with", 6, 17, 50)

    edit(repo, "layout/wires.tcl", "p metal1 146.4 15.2 147.6 16.4      ;# landing pad under the VDPWR stripe",
         "p metal1 146.2 15.0 147.8 16.6      ;# landing pad under the VDPWR stripe")
    edit(repo, "layout/wires.tcl", "p metal2 146.4 15.2 147.6 16.4\np metal3 146.4 15.2 147.6 16.4",
         "p metal2 146.2 15.0 147.8 16.6\np metal3 146.2 15.0 147.8 16.6")
    step(SAM, "Widen the VDPWR landing pad to match VGND's", 6, 18, 20, layout=True)

    # 13: a GDS cut short. Magic reads part of it and reports 66 errors in what it got.
    edit(repo, "layout/wires.tcl", "place ic102_inv 140 10 inv0",
         "place ic102_inv 140 10 inv0\nplace ic102_inv 140 30 inv1   ;# second inverter, not wired yet")
    build(repo, (2026, 10, 7, 23, 55, 0))
    gds = repo / f"gds/{TOP}.gds"
    gds.write_bytes(gds.read_bytes()[:6000])          # what Magic left when it crashed mid-write
    commit(repo, c + 1, SAM, "Add a second inverter (WIP)", 7, 23, 55)
    c += 1

    step(SAM, "Rebuild gds/ and lef/: Magic crashed while writing the last ones", 8, 9, 40,
         layout=True)

    append(repo, "docs/info.md", "\nA second inverter, to make a buffer, is placed but not wired yet.\n")
    step(SAM, "docs: mention the second inverter", 8, 10, 0)

    append(repo, "docs/info.md", "\nThe pins again: ua[0] is in, ua[1] is out.\n")
    step(AVERY, "docs: repeat the pin names under How to test", 9, 9, 15)

    edit(repo, "info.yaml", 'discord:      ""', 'discord:      "avery_example"')
    step(AVERY, "info.yaml: add a Discord handle", 9, 9, 20)

    # 18: the first bad commit. Y's metal2 now comes within 0.10 um of A's.
    edit(repo, "layout/wires.tcl", "p metal2 132.64 13.26 142.6 13.71",
         "p metal2 132.64 12.85 142.6 13.71")
    step(SAM, "Widen Y's wire to ua[1]\n\nThe output wire carries more current than the input "
         "one, so give it twice the width.", 11, 22, 40, layout=True)

    append(repo, "README.md", "\n## Credits\n\nThe inverter cell is AD104 Lab 03's reference cell "
           "(github.com/uoftasic/ad104).\n")
    step(SAM, "README: credit the inverter cell", 12, 14, 0)

    # 20: no gds/ at all. Magic finds no cell to read, checks an empty one, reports 0 errors.
    edit(repo, ".gitignore", "layout/build/", "layout/build/\ngds/\nlef/")
    run(["git", "rm", "-q", "-r", "--cached", "gds", "lef"], repo)
    step(AVERY, "Keep build output out of git", 13, 11, 30)

    edit(repo, ".gitignore", "layout/build/\ngds/\nlef/", "layout/build/")
    step(AVERY, "Put gds/ and lef/ back: the gds workflow reads them from the repository", 13, 12, 5)

    append(repo, "docs/info.md", "\nEach analog pin has less than 500 ohms of series resistance "
           "on its way to the pad, according to Tiny Tapeout's analog specs.\n")
    step(AVERY, "docs: note the analog pin resistance", 14, 10, 5)

    append(repo, ".gitignore", "\n# Magic's crash dumps\ncore\n")
    step(AVERY, "Ignore core dumps", 14, 10, 30)

    edit(repo, "README.md", "then `make precheck` and `make lvs`.",
         "then `make precheck` and `make lvs`. Commit gds/ and lef/ together with the change "
         "that made them.")
    step(SAM, "README: commit gds/ and lef/ with the change that made them", 15, 16, 45)

    append(repo, "docs/info.md", "\nThe inverter's input threshold is roughly half of VDPWR.\n")
    step(SAM, "docs: say where the input threshold is", 16, 19, 10)

    edit(repo, "README.md", "## Building the layout", "## Building and checking the layout")
    step(AVERY, "README: rename the build section", 17, 13, 0)

    edit(repo, "info.yaml", '"A CMOS inverter from AD104, wired to ua[0] and ua[1]"',
         '"A CMOS inverter from AD104 between ua[0] and ua[1]"')
    step(AVERY, "info.yaml: shorten the description", 18, 12, 30)

    edit(repo, "layout/wires.tcl", "\nplace ic102_inv 140 30 inv1   ;# second inverter, not wired yet", "")
    edit(repo, "docs/info.md", "\nA second inverter, to make a buffer, is placed but not wired yet.\n", "")
    step(SAM, "Remove the unwired second inverter until there's time to wire it", 19, 20, 15,
         layout=True)

    append(repo, "README.md", "\n## Status\n\nPrecheck and LVS pass on v0.1.\n")
    step(AVERY, "README: add a status section", 20, 11, 0)

    edit(repo, "docs/info.md", "roughly half of VDPWR", "a little under half of VDPWR")
    step(SAM, "docs: the threshold is a little under VDPWR/2", 21, 18, 30)

    append(repo, "docs/info.md", "\n## External hardware\n\nA signal generator and an oscilloscope.\n")
    edit(repo, "docs/info.md", "## External hardware\n\nList external hardware used in your project "
         "(e.g. PMOD, LED display, etc), if any\n", "", 1)
    step(AVERY, "docs: list the external hardware", 22, 9, 45)

    edit(repo, "README.md", "A practice project made from Tiny Tapeout's analog template.",
         "A practice project made from Tiny Tapeout's analog template, for IC102-A Lab 05.")
    step(AVERY, "README: say which lab this is for", 23, 14, 20)

    append(repo, "README.md", "\nThe gds workflow has been red since some time after v0.1.\n")
    step(SAM, "README: note that the gds workflow is red", 26, 21, 5)

    bundle = out
    run(["git", "bundle", "create", "-q", str(bundle), "HEAD", "main", "v0.1"], repo)
    print(f"{c} commits; bundle written to {bundle}")


if __name__ == "__main__":
    main()
