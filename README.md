# IC102-A — Working in Tiny Tapeout Repos (Analog)

Run an analog Tiny Tapeout project the way the team does: your own repo from the template, a
layout that passes precheck, reviewed pull requests, and history you can use.

Part of the UofT ASIC Team education materials (`uoftasic`).
Course site: <https://uoftasic.com/ic102-a/> · Education hub: <https://edu.uoftasic.com/>

The course is about the repository around an analog design rather than the design itself. Each
lab ships the layout it needs, so it assumes IC101 and nothing else. The digital version is
[IC102-D](https://github.com/uoftasic/ic102-d), and eight of the guide pages are shared with it.

## Quick start

Everything runs inside the team workbench image `hpretl/iic-osic-tools:2026.08`, plus a copy of
the tool versions Tiny Tapeout's precheck uses on GitHub (Magic 8.3.568, KLayout 0.30.8, sky130A
at `0536d02d`), which `labs/common/tt-tools` installs next to the image's. Students set up through
the shared `workspace` and the noVNC desktop from [IC101](https://uoftasic.com/ic101/);
[Lab 01, Part 1](https://uoftasic.com/ic102-a/labs/lab-01-your-repo-from-the-template-overview.html)
has the steps. In a terminal on that desktop:

```bash
. /foss/designs/common/.designinit
mod add ic102-a                     # first time only
mod ic102-a
cd labs/common/tt-tools
make install && make selftest       # about 1.8 GB; selftest ends on "Precheck passed"
```

The labs also need a GitHub account, because half of each one happens on GitHub.

## Lab packages

| Path | What it is | Writeup |
|---|---|---|
| `labs/common/tt-tools/` | precheck's own tool versions, installed locally, and `make precheck` | used by every lab |
| `labs/lab-01-your-repo-from-the-template/` | the layout kit a student's repository starts from | Lab 01 |
| `labs/lab-02-read-the-red-x/` | `break.sh`: five numbered mistakes, and the `DIAGNOSIS.md` template | Lab 02 |
| `labs/lab-03-a-layout-that-passes-precheck/` | the AD104 inverter, its wiring with one wire left out, and an LVS reference | Lab 03 |
| `labs/lab-04-a-change-through-review/` | `sandbox/`: the cohort's shared repository, with its ruleset and review checklist | Lab 04 |
| `labs/lab-05-find-the-commit-that-broke-it/` | a 33-commit layout history as a git bundle, and precheck's Magic DRC as a script | Lab 05 |

Reference solutions are in each package's `solutions/`.

## Docs

The course site is built with Quarto from `./docs`. `docs/_quarto.yml` holds the site, sidebar
and navbar, and `docs/_quarto-pdf.yml` builds the whole course as one PDF. With
[Quarto](https://quarto.org/docs/get-started/) 1.11:

```bash
quarto preview docs                           # http://localhost:4200
quarto render docs --profile pdf --to typst   # the whole course as one PDF in docs/_book/
```

The eight shared guide pages (`git-in-one-page.md`, `templates-forks-and-clones.md`,
`what-a-cloud-runner-is.md`, `reading-a-workflow-file.md`, `pull-requests-and-review.md`,
`branch-rules.md`, `how-open-source-projects-work.md` and `history-as-evidence.md`) are written in
the IC102-D repository and copied here by its `scripts/sync_shared_pages.py`. Edit them there.

[AGENTS.md](AGENTS.md) describes the course structure, and [CONTRIBUTING.md](CONTRIBUTING.md) the
repository's conventions.
