# Devcontainer

Node 22 with Claude Code, Codex, Copilot CLI and the GitHub CLI. Each tool keeps its login in a volume of its own per container: logins survive rebuilds and aren't shared with your other devcontainers.

## Get it into a repo

- **New repo:** on GitHub, **Use this template → Create a new repository**, then clone it.
- **Existing repo** (the same commands also update a repo to the latest template):

  ```sh
  git fetch https://github.com/nevva/devcontainer-agents-base main
  git checkout FETCH_HEAD -- .devcontainer        # add AGENTS.md CLAUDE.md if you have none yet
  git commit -m "Add devcontainer from devcontainer-agents-base"
  ```

## Setup

1. Open the folder in VS Code and choose **Reopen in Container** (or run `devcontainer up --workspace-folder .`).
2. Log in to GitHub. A new terminal shows the steps until you're logged in (to show them again, run `bash .devcontainer/welcome.sh`):
   - Open the pre-filled token link and set **Repository access → Only select repositories →** this repo.
   - Run `gh auth login --with-token`, paste the token, press Enter, then Ctrl-D.
   - With `GH_LOGIN=oauth` the steps differ: see [OAuth login](#oauth-login-github-packages).
3. Log in to the agents: run `claude`, and `codex` or `copilot` if you use them.
4. Edit `AGENTS.md` (`CLAUDE.md` just imports it) with your project's own rules.

## OAuth login (GitHub Packages)

Fine-grained tokens can't read GitHub Packages. If the project installs private npm packages from there, switch this repo to a `gh auth login` OAuth token in `devcontainer.json`:

```jsonc
"containerEnv": {
  // ...keep the existing entries
  "GH_LOGIN": "oauth",                  // default "token": the fine-grained, single-repo token
  "GH_SCOPES": "read:packages",         // comma-separated; the steps show until the token has them all
  "GH_EXPORT_NODE_AUTH_TOKEN": "1"      // export NODE_AUTH_TOKEN=$(gh auth token) in new shells, for .npmrc
}
```

Rebuild the container; the steps then show `gh auth login --web --scopes ...` (or `gh auth refresh --scopes ...` when already logged in). If an organization uses SAML SSO, authorize it in the browser during login.

Trade-off: this token reaches every repo your account can access, and anything in the container (agents included) can use it. Use the default token mode unless you need the extra scopes.

## Add-ons

Optional features: `chrome-mcp` (agents drive a Chrome on your host) and `korp` (Korp's code index, tasks and decisions for agents). To add some, ask your agent:

> Follow `.devcontainer/ADD-ONS.md`.

It asks which add-ons you want, edits `devcontainer.json`, explains them to future agents in `AGENTS.md`, and lists what you still need to do yourself.

## Good to know

- In `token` mode the token can only reach this repo: code and pull requests, for 90 days. Add `workflows=write` to the link if you will edit `.github/workflows`. When it expires, the steps show up again; make a new token and log in again.
- git authenticates to github.com only through `gh` (set in `.git/config` by `post-create.sh`), so the host credentials VS Code forwards aren't used.
- If you delete a container's volumes, you have to log in again.
