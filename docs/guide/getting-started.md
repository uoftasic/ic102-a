# Getting started

IC102-A is about the repository around an analog Tiny Tapeout design rather than the design
itself. Every analog project on a Tiny Tapeout shuttle lives in a GitHub repository made from Tiny
Tapeout's analog template, and that repository checks your layout on GitHub's machines each time
you push. In this course you make one of those repositories, learn to read what its checks report,
put a small layout in it that passes them, get a change reviewed in a repository you share with
your cohort, and use the history to find a commit that broke something.

You don't need to know how to draw layout. Each lab ships the layout it needs: Tiny Tapeout's
empty frame in Lab 01, the CMOS inverter from AD104 Lab 03 in Lab 03, and a prepared project in
Lab 05. You'll edit a few lines of the scripts that place and wire them, and the course's checks
tell you whether the result is right. If you've done AD104, the cell will be familiar; if you
haven't, nothing here depends on it.

## How the course is laid out

The [course path](../index.md#course-path) on the home page lists every page in the order to work
through them. A Read row points to guide pages like this one, which explain things and have no
commands for you to run. A Do row points to a lab writeup, and every command in the course is in a
lab. Each lab is split into parts with numbered steps, most parts start with the question they
answer, and each ends with a "You should see" or "Check" line that tells you whether it worked.
When a step asks a question, its answer is in a collapsed block under it; try it first, then open
the block. Some steps ask you to predict a result before you see it, which is worth doing honestly,
because a wrong prediction is the quickest way to find out what you misunderstood.

The files the labs run are in the course's repository, under
[`labs/`](https://github.com/uoftasic/ic102-a/tree/main/labs). You'll get them into the workbench
with `mod add ic102-a` in Lab 01.

## Two places your work happens

Your work in this course happens in two places, and it's worth keeping them straight from the
start.

**The workbench** is the IIC-OSIC-TOOLS desktop you set up in [IC101](https://uoftasic.com/ic101/).
That's where you build layouts with Magic, run checks, and use git: every command in the labs is
typed into a terminal on that desktop. Your repositories go in a `projects` folder of your
workspace, `/foss/designs/projects`, which is the `workspace` folder on your own disk, so they
survive when the workbench restarts. Anything outside `/foss/designs` doesn't: the container's
home folder is thrown away with the container, and that has one consequence you'll meet in Lab 01,
which is that git's settings have to be stored in each repository rather than in your home folder.

**GitHub** is where your repository lives, and where its workflows run each time you push, on
GitHub's machines (the *runners*). [What a cloud runner is](what-a-cloud-runner-is.md) explains
what those are. Some things can only be done there: making the repository, turning on Pages,
opening and reviewing pull requests, reading a run's results.

Tiny Tapeout's precheck, the most important of those results, doesn't use the workbench's tools.
It installs its own versions of Magic, KLayout and the PDK on the runner, and a layout that passes
with one set can fail with the other. So in Lab 01 you'll install precheck's versions next to the
workbench's, and `make precheck` gives you the runner's verdict on your own machine before you
push. [Your tools and the runner's tools](your-tools-and-the-runners-tools.md) has the details.
IC102-A follows Tiny Tapeout's versions on purpose; the other courses use the workbench's.

## Your GitHub account

You'll work in your own GitHub account throughout, so all you need is a free account. Your
repository for the labs is public, because GitHub Pages, which the template's `viewer` job needs,
works only in public repositories on a free account, and because GitHub's runners are free and
unlimited for public repositories. Remember that everything in a public repository is public: your
commits, the `author` field in `info.yaml`, and the email address in every commit. Lab 01 has you
use GitHub's no-reply address for that reason.

You'll also become a member of the team's GitHub organization, `uoftasic`. That's how you get into
Lab 04's shared repository and, later, into the team's own projects. Membership gives you write
access to every one of the organization's repositories, which is a lot of trust;
[Branch rules](branch-rules.md) says what that means in practice.

## Pushing from the workbench

GitHub doesn't accept your account's password for `git push`. From the workbench you push over
HTTPS with a **personal access token**, a long random string that stands in for a password and that
you can limit to particular repositories and permissions. Lab 01 has you make a fine-grained token
with two permissions, both "Read and write":

- **Contents**, which is what pushing commits needs.
- **Workflows**, because GitHub refuses a push that adds or changes a file in
  `.github/workflows/` unless the token has it. You won't edit a workflow in this course, but in
  Lab 05 you push a whole project's history, workflow files included, to a new branch.

When `git push` asks for a password, you paste the token. A line in Lab 01 tells git to keep it in
memory for ten hours, so you're asked once a session. Keep the token in a password manager, not in
a file under `/foss/designs`: that folder is your workspace, itself a git repository, and a token
saved there is one careless `git add` away from being published.

## Using AI tools

You may use AI tools such as Claude, ChatGPT or Copilot to help with the work in this course, to
explain an error message, write a script or draft a pull request description. The rules are the
ones in [Pull requests and review](pull-requests-and-review.md#pull-requests-written-with-ai-tools):
you answer for every line you submit, however it was written, and you say in a pull request which
parts a tool wrote and what you checked yourself. The labs are built so that the checks, not the
tool, tell you when you're right: an LVS report doesn't care who drew the wire.

## Where the course stops

IC102-A takes a project as far as "ready to submit": every workflow green, including precheck, on
a commit you made and can name. It doesn't cover submitting to a shuttle. You won't create a
project on `app.tinytapeout.com`, pay, or use a coupon, and nothing in the course depends on a
shuttle being open. Every project you make here is practice, and Lab 04's shared repository is
never submitted.

## Getting help

Ask in the [team Discord](https://discord.gg/hrJnP5UsGz). A question that can be answered quickly
has three things in it: the lab, part and step you're on; the command you ran; and the output,
pasted as text rather than a photo, from the first line that looks wrong. If it's about a run on
GitHub, include the link to the run. Logs on GitHub are deleted after 90 days, so if the question
might matter later, paste the error line itself as well.

## Check yourself

1. You restart the workbench, open a terminal, and `git commit` stops with
   `Author identity unknown`. You set your name and email in Lab 01. What happened?

   <details>
   <summary>Answer</summary>

   You set them with `--global`, which writes them to the container's home folder, and the restart
   threw that folder away. Set them again without `--global`, inside the repository, where they're
   stored in `.git/config` on your own disk.

   </details>

2. Why does the course install a second Magic when the workbench already has one?

   <details>
   <summary>Answer</summary>

   Because precheck, which decides whether your layout passes, uses Magic 8.3.568 with a
   particular commit of the PDK, and the workbench has Magic 8.3.681 with a different one. Running
   precheck's own versions locally means a pass on your machine predicts a pass on the runner.

   </details>
