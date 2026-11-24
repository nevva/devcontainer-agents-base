#!/usr/bin/env bash
# Printed in each interactive terminal until gh holds a working token with every scope in GH_SCOPES.

IFS=', ' read -ra want <<<"${GH_SCOPES:-}"

# Scopes that grant $1: itself and its parents.
grants() {
  echo "$1"
  case $1 in
    read:*) echo "write:${1#read:} admin:${1#read:}" ;;
    write:*) echo "admin:${1#write:}" ;;
  esac
  case $1 in
    repo:* | public_repo | repo_deployment | security_events) echo repo ;;
    user:* | read:user) echo user ;;
    manage_runners:org) echo admin:org ;;
    manage_*:enterprise) echo admin:enterprise ;;
    read:project) echo project ;;
    codespace:secrets) echo codespace ;;
  esac
}

missing=()
if headers=$(timeout 5 gh api -i user 2>/dev/null); then
  # Fine-grained tokens send no X-OAuth-Scopes header, so they lack every scope.
  have=" $(grep -i '^x-oauth-scopes:' <<<"$headers" | cut -d: -f2- | tr ',\r' '  ') "
  for scope in "${want[@]}"; do
    ok=
    for g in $(grants "$scope"); do
      [[ $have == *" $g "* ]] && ok=1
    done
    [ -n "$ok" ] || missing+=("$scope")
  done
  [ ${#missing[@]} -eq 0 ] && exit 0
  status="GitHub: the token lacks ${missing[*]}."
else
  status="GitHub: not logged in."
fi

if [ "${GH_LOGIN:-token}" = oauth ]; then
  [ -n "${GH_SCOPES:-}" ] && scopes=" --scopes \"$GH_SCOPES\""
  cat <<MSG

  $status Log in with your GitHub account:

  1. Run:  gh auth login --hostname github.com --git-protocol https --web${scopes:-}
MSG
  [ -n "${GH_SCOPES:-}" ] && echo "     Already logged in? Run:  gh auth refresh --scopes \"$GH_SCOPES\""
  cat <<MSG
  2. If an organization uses SAML SSO, authorize it in the browser during login.

  This token reaches every repo your account can access, not only this one.
  It lives in this container's volume and survives rebuilds.

MSG
  exit 0
fi

url=$(git -C "$(dirname "$0")/.." remote get-url origin 2>/dev/null)
repo=$(sed -E 's#(\.git)?$##; s#^.*github\.com[:/]##' <<<"$url")
owner=${repo%%/*}
name=${repo#*/}

cat <<MSG

  $status Give this devcontainer a token scoped to ${repo:-this repo} only:

  1. Open (pre-filled: Contents + Pull requests write, 90 days):
     https://github.com/settings/personal-access-tokens/new?name=${name:0:40}&target_name=${owner}&expires_in=90&contents=write&pull_requests=write
     Under "Repository access" pick "Only select repositories" -> ${repo:-the repo}.
     Add workflows=write to the URL if you will edit .github/workflows.
  2. Run:  gh auth login --with-token
     Paste the token, press Enter, then Ctrl-D.

  git push and gh pr create then work. The token lives in this container's volume and survives rebuilds.

MSG
