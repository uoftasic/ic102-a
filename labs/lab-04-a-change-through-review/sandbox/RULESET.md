# The ruleset on main

A repository you create gets no rules of its own, so you set this ruleset up by hand, under
Settings › Rules › Rulesets › New ruleset › **Import a ruleset**, where you choose
[ruleset.json](ruleset.json) from your clone. We imported it into a test repository on Nov 16,
2026, and GitHub took it as written. Even so, check what the page shows against this table before
you press **Create**.

| Part | Setting | Why |
|---|---|---|
| Name | main: one approval and green checks | |
| Enforcement | Active | An "Evaluate" ruleset only reports; it blocks nothing |
| Target | The default branch (`~DEFAULT_BRANCH`) | A ruleset with no target protects no branch |
| Restrict deletions | On | |
| Block force pushes | On | A force push to `main` would rewrite the history everyone else's branch starts from |
| Require a pull request before merging | On, 1 approval | Every change except yours gets an approval from someone other than its author; you merge yours with the bypass below |
| Dismiss stale approvals when new commits are pushed | On | An approval covers the commit it was given on; a merge that rebuilt the GDS is a new layout |
| Require approval of the most recent reviewable push | On | Someone other than the person who pushed the last commit has to approve it, so a change pushed after an approval can't ride on that approval |
| Require conversation resolution before merging | On | A requested change has to be answered before the merge |
| Require an additional approval for unattributed Copilot pull requests | On | GitHub's default, not in the file; it matters only for a pull request that Copilot opens by itself |
| Allowed merge methods | Merge | Keeps each claim, and the merge that resolved its conflict, in the history |
| Require status checks to pass | `docs`, `gds`, `precheck` | The three jobs that run on a pull request |
| Require branches to be up to date before merging | Off | A pull request that conflicts can't be merged anyway, and resolving the conflict is what brings it up to date |
| Bypass list | Repository admin, "Allow for pull requests only" (the menu calls it "For pull requests only") | Explained below |

Only an approval from someone with write access to the repository counts towards the one the rule
asks for. On a repository in your own account, that's you, as its admin, and nobody else. So you
can approve your partner's pull request, but nobody can approve a pull request of your own. The
bypass entry lets you merge your own pull request without an approval; wait until its checks have
passed before you do. "For pull requests only" means the bypass applies only to merging a pull
request: GitHub rejects a direct push to `main` from you as it does from everyone else, so every
change still arrives as a pull request with its runs and its diff in one place.

`viewer` isn't a required check. It's skipped on pull requests (see the comment in
`.github/workflows/gds.yaml`), and when a merge is pushed to `main` it runs and publishes `main`'s
layout to Pages.

Two repository settings go with the ruleset:

- Settings › Pages › Build and deployment › Source: GitHub Actions, so that `viewer` can deploy.
  Pages is off in a new repository, so `viewer` fails on the first push. After you turn Pages on,
  start a new run (Actions › `gds` › **Run workflow** on `main`) rather than re-running the failed
  one.
- Settings › Actions › General › "Approval for running fork pull request workflows from
  contributors": leave GitHub's default, "Require approval for first-time contributors". First-time
  contributors are people who have never had a commit or pull request merged into the repository,
  and your partner is one, so their pull request's runs wait until you approve them. GitHub's
  documentation gives the steps
  ([approving workflow runs from forks](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/approve-runs-from-forks#approving-workflow-runs-on-a-pull-request-from-a-public-fork)).
  On the pull request's **Files changed** tab, read the change, because the runs will execute it.
  A `pull_request` run uses the workflow files from the pull request itself, so check that nothing
  under `.github/` changed. Then press **Awaiting approval**, in the upper right corner of the page,
  to open the **Merge status** panel, and press **Approve workflows to run** in it.
