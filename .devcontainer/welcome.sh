#!/usr/bin/env bash
# Printed in each interactive terminal until gh holds a working token.

if user=$(timeout 5 gh api user --jq .login 2>/dev/null); then
  exit 0
fi

url=$(git -C "$(dirname "$0")/.." remote get-url origin 2>/dev/null)
repo=$(sed -E 's#(\.git)?$##; s#^.*github\.com[:/]##' <<<"$url")
owner=${repo%%/*}
name=${repo#*/}

cat <<MSG

  GitHub: not logged in. Give this devcontainer a token scoped to ${repo:-this repo} only:

  1. Open (pre-filled: Contents + Pull requests write, 90 days):
     https://github.com/settings/personal-access-tokens/new?name=${name:0:40}&target_name=${owner}&expires_in=90&contents=write&pull_requests=write
     Under "Repository access" pick "Only select repositories" -> ${repo:-the repo}.
     Add workflows=write to the URL if you will edit .github/workflows.
  2. Run:  gh auth login --with-token
     Paste the token, press Enter, then Ctrl-D.

  git push and gh pr create then work. The token lives in this container's volume and survives rebuilds.

MSG
