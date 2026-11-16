#!/usr/bin/env bash
# IC102-A Lab 04, Part 7 (optional): put the course's AI-written pull request on
# a new branch of the sandbox clone you're in, and push the branch.
#
# Run it from the top of your clone of your fork of your partner's review
# repository (ttsky-ic102-a-review-fork), once your own pull request there has
# been merged:
#
#   /foss/designs/modules/ic102-a/labs/lab-04-a-change-through-review/ai-pr/ai-pr.sh
#
# It branches from your partner's main (the remote `upstream`), commits the
# change, and pushes the branch to your fork (`origin`). Then open a pull
# request from that branch into your partner's main, with the description it
# prints (pr-body.md, next to this script, with the slot filled in). Your
# partner reviews it, and you review the one they open on your repository.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ -f layout/slots.tcl ] && [ -f layout/cells/ic102_inv.mag ] \
  || { echo "ai-pr.sh: run this from the top of a clone of an IC102-A sandbox"; exit 1; }
[ -z "$(git status --porcelain --untracked-files=no)" ] \
  || { echo "ai-pr.sh: commit or undo your changes first (git status lists them)"; exit 1; }
base=origin
git remote get-url upstream > /dev/null 2>&1 && base=upstream
git fetch -q "$base"

# The lowest free slot K whose neighbour K+1 is free too, on the partner's main.
claimed=$(git show "$base/main:layout/slots.tcl" | sed -n 's/^ *slot \([0-7]\) .*/\1/p')
k=
for i in 0 1 2 3 4 5 6; do
  if ! grep -qx "$i" <<< "$claimed" && ! grep -qx "$((i + 1))" <<< "$claimed"; then k=$i; break; fi
done
[ -n "$k" ] || { echo "ai-pr.sh: no two free neighbouring slots on $base/main"; exit 1; }
branch=ai/claim-slot-$k
git switch -q -c "$branch" "$base/main"

# The change, as the AI tool wrote it.
cp layout/cells/ic102_inv.mag layout/cells/inv_ai.mag
printf 'slot %s inv_ai\n' "$k" >> layout/slots.tcl
n=$((k + 1))
sed -i "s/^  ui\[$n\]: \"\"/  ui[$n]: \"AI inverter input\"/; s/^  uo\[$n\]: \"\"/  uo[$n]: \"AI inverter output\"/" info.yaml
printf '\n# Build output\ngds/\nlef/\n' >> .gitignore

git add layout/cells/inv_ai.mag layout/slots.tcl info.yaml .gitignore
git commit -q -m "Add an inverter in slot $k"
git push -q -u origin "$branch"
echo "Pushed $branch to origin. Open a pull request from it into your partner's main, titled"
echo "\"Claim slot $k: AI inverter\", and paste everything below the line as its description."
echo "----------------------------------------------------------------------------------------"
sed "s/SLOT/$k/g" "$here/pr-body.md"
