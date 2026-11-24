# Scripts

Utilities for IC102-A — Working in Tiny Tapeout Repos (Analog) under the UofT ASIC org (`uoftasic`).

## Entry points

| Script | Purpose |
|--------|---------|
| `check_site.py` | Check that every local link and `#anchor` in the rendered site resolves, and that every page has the navbar's link to https://edu.uoftasic.com/; `.github/workflows/site.yml` runs it on `docs/_site` |
| `init-template.py` | Fill the course id, title and description after using the course template (already done for this course) |
| `figures/` | The scripts that draw the shared guide pages' diagrams in `docs/assets/img/` with schemdraw. `pip install -r scripts/figures/requirements.txt`, then `python3 scripts/figures/<name>.py` rewrites that figure's SVG. They're copied from IC102-D with the pages, so edit them there |

The lab packages' own scripts are under `labs/`, and each package's `README.md` lists them.

## Conventions

- Write scripts in Python where you can. EDA tooling belongs in `labs/` or the shared workbench.
- Keep secrets out of the repo. If a script needs configuration, add a `.env.example`.
- When you add a script, add it to the table above.
