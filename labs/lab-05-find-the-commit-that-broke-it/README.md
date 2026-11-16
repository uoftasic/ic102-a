# Lab 05: Find the commit that broke it

Writeup: [uoftasic.com/ic102-a → Lab 05](https://uoftasic.com/ic102-a/labs/lab-05-find-the-commit-that-broke-it-overview.html)

`history.bundle` is a small analog project's history, 33 commits long, with a tag `v0.1` on the
last commit everyone agrees was good. Somewhere after it, Magic DRC started failing. You write a
script that `git bisect run` can trust, find the commit, and revert it in a pull request, in a
repository of your own, `ttsky-ic102-a-bisect`.

## Run it

In a workbench terminal:

```bash
mkdir -p /foss/designs/projects && cd /foss/designs/projects
git clone /foss/designs/modules/ic102-a/labs/lab-05-find-the-commit-that-broke-it/history.bundle ttsky-ic102-a-bisect
```

| Script | What it does |
|---|---|
| `magic-drc.sh GDS TOP DIR` | precheck's Magic DRC on one GDS, with precheck's Magic and PDK; writes `DIR/magic_drc.txt` and `DIR/magic.log`, and exits with Magic's status |
| `first-try.sh` | a first attempt at a bisect script, to read and predict before you run it |

## Files

| File | What it is |
|---|---|
| `history.bundle` | the history, as a git bundle |
| `magic-drc.sh`, `first-try.sh` | the two scripts above |
| `solutions/bisect.sh` | a script that finds the right commit. Open it after yours works |
| `maintainer/make-history.py` | builds `history.bundle`. For maintainers: its docstring says how, and what changes if you change it |
