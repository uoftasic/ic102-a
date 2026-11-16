# IC102-A — Working in Tiny Tapeout Repos (Analog)

In this course you run an analog Tiny Tapeout project the way the team's projects should be run:
your own repository made from Tiny Tapeout's analog template, a layout in it that passes precheck,
a change that reaches `main` through a reviewed pull request, and a history you can use to find
the commit that broke something.

IC102-A is part of the UofT ASIC Team education materials, published at <https://uoftasic.com/ic102-a/>.
The labs run in the workbench, the IIC-OSIC-TOOLS container you start from the `workspace` clone
you set up in [IC101](https://uoftasic.com/ic101/), and on GitHub. You get this course's files with
the workbench's `mod` command (`mod add ic102-a`);
[Lab 01, Part 1](labs/lab-01-your-repo-from-the-template-overview.md#part-1-load-the-course) walks
you through it.

## Who this course is for

Anyone who will push to an analog Tiny Tapeout repository: an ASIC Zoo designer, someone joining a
team project with an analog block, or someone starting one of their own. It's the course to take
after IC101 and before your first push, and it assumes nothing beyond IC101: no Verilog and no
layout. Each lab ships the layout it needs, from Tiny Tapeout's empty frame to the CMOS inverter
from AD104, and the work you do is around it: filling in the template, reading failed runs, wiring
the cell to the tile's pins, reviewing and merging, and searching a history.

IC102 comes in two versions. Take this one, IC102-A, if you draw your layout yourself in Magic and
commit the GDS, as in ASIC Zoo and CrossWalk's analog blocks. Take
[IC102-D](https://uoftasic.com/ic102-d/) if your project is written in Verilog and the GDS action
builds its layout. About half the reading is the same in both.

| | |
|---|---|
| Track | Core, after IC101 |
| Prerequisites | [IC101](https://uoftasic.com/ic101/), and a GitHub account |
| Tools | The workbench image `hpretl/iic-osic-tools:2026.08`, plus the versions of Tiny Tapeout's precheck tools that its runners use (Magic 8.3.568, KLayout 0.30.8, the sky130A PDK at `0536d02d`), which Lab 01 installs next to the workbench's |
| Machine | The workbench you already have, about 2 GB more disk for those tools, and an internet connection. Most layout commands take under a second; a local precheck takes about 45 s, and a run on GitHub a few minutes |
| Total time | About 8 h 45 min, self-paced, including the waits for GitHub's runners. The Course path rows below add up to 8 h 45 min. |

The course stops at "ready to submit": every workflow green on a commit you made. It doesn't cover
submitting a project to a shuttle, and nothing in it depends on a shuttle being open.

## Course path

Work down this table in order. A Read row is a set of guide pages, which are for reading only and
have no commands in them. A Do row is one lab writeup, and the lab writeups are where every command
in the course lives. Each lab's "Before you start" section repeats which pages it expects you to
have read.

| # | | What | Time |
|---|---|---|---|
| 1 | Read | [Getting started](guide/getting-started.md) · [Git in one page](guide/git-in-one-page.md) · [Templates, forks and clones](guide/templates-forks-and-clones.md) | 35 min |
| 2 | Do | [Lab 01: Your repository from the template](labs/lab-01-your-repo-from-the-template-overview.md). Make your own repository from Tiny Tapeout's analog template, fill it in, commit Tiny Tapeout's empty frame as a placeholder layout, and turn on Pages until every job of every workflow is green. | 1 h 15 min |
| 3 | Read | [What a cloud runner is](guide/what-a-cloud-runner-is.md) · [Reading a workflow file](guide/reading-a-workflow-file.md) · [The analog workflows](guide/the-analog-workflows.md) | 40 min |
| 4 | Do | [Lab 02: Read the red X](labs/lab-02-read-the-red-x-overview.md). Push five broken versions of your repository, from the team's mistakes and precheck's rules, and for each write down the job, the step and the first error line before you fix it. | 1 h 10 min |
| 5 | Read | [The analog layout kit](guide/the-analog-layout-kit.md) · [What precheck checks](guide/what-precheck-checks.md) · [Your tools and the runner's tools](guide/your-tools-and-the-runners-tools.md) | 35 min |
| 6 | Do | [Lab 03: A layout that passes precheck](labs/lab-03-a-layout-that-passes-precheck-overview.md). Place the AD104 inverter in your tile, move the power stripes, draw its output wire to `ua[1]`, and get DRC, LVS and precheck to pass before you merge it through a pull request. | 1 h 45 min |
| 7 | Read | [Pull requests and review](guide/pull-requests-and-review.md) · [Branch rules](guide/branch-rules.md) · [Layout files in git](guide/layout-files-in-git.md) · [How open-source projects work](guide/how-open-source-projects-work.md) | 45 min |
| 8 | Do | [Lab 04: A change through review](labs/lab-04-a-change-through-review-overview.md). Claim a slot in your cohort's shared layout with a pull request, review a classmate's from the render and the precheck table, and rebuild the layout after a conflict. | 1 h |
| 9 | Read | [History as evidence](guide/history-as-evidence.md) | 15 min |
| 10 | Do | [Lab 05: Find the commit that broke it](labs/lab-05-find-the-commit-that-broke-it-overview.md). Write a DRC script that `git bisect run` can trust, find the commit that broke a 33-commit layout history, and revert it in a pull request. | 45 min |

## Getting help

Ask in the [team Discord](https://discord.gg/hrJnP5UsGz); nobody expects you to work all of this
out alone. [Getting started](guide/getting-started.md#getting-help) says what to put in a question
so it can be answered quickly.
