# The ruleset on main

A repository made from a template doesn't get the template's settings, so whoever creates this
sandbox sets this ruleset up by hand, under Settings › Rules › Rulesets. [ruleset.json](ruleset.json)
holds the same settings as JSON, for the page's New ruleset › Import a ruleset. Nobody has
imported it yet, because the first sandbox hasn't been created; check the imported ruleset
against this table before you press Create.

| Part | Setting | Why |
|---|---|---|
| Name | main: one approval and green checks | |
| Enforcement | Active | An "Evaluate" ruleset only reports; it blocks nothing |
| Target | The default branch (`~DEFAULT_BRANCH`) | A ruleset with no target protects no branch |
| Restrict deletions | On | |
| Block force pushes | On | A force push to `main` would rewrite everyone's base |
| Require a pull request before merging | On, 1 approval | Every change is seen by someone other than its author |
| Dismiss stale approvals when new commits are pushed | On | An approval covers the commit it was given on; a merge that rebuilt the GDS is a new layout |
| Require approval of the most recent reviewable push | On | Someone other than the person who pushed the last commit has to approve it, so a change pushed after an approval can't ride on that approval |
| Require conversation resolution before merging | On | A requested change has to be answered before the merge |
| Allowed merge methods | Merge | Keeps each student's commits, and their slot claim, in the history |
| Require status checks to pass | `docs`, `gds`, `precheck` | The three jobs that run on a pull request |
| Require branches to be up to date before merging | Off | Every pull request here conflicts with the one before it anyway, and resolving that conflict is what brings it up to date |
| Bypass list | Empty | Nobody, the course's TAs included, can merge around the rules |

`viewer` isn't a required check. It's skipped on pull requests (see the comment in
`.github/workflows/gds.yaml`), and it runs, and publishes `main`'s layout to Pages, when the merge
is pushed to `main`.

Two repository settings go with the ruleset:

- Settings › Pages › Build and deployment › Source: GitHub Actions, so that `viewer` can deploy.
- Settings › Actions › General › "Approval for running fork pull request workflows from
  contributors": "Require approval for all external contributors". GitHub's default is "Require
  approval for first-time contributors", meaning anyone who has never had a commit or pull
  request merged into the repository, and in a new sandbox that is every student, so each
  student's first run would wait for someone to press "Approve and run". The external-contributors
  setting exempts members of the organization, which every student in IC102-A is, and still holds
  back pull requests from anyone else.
