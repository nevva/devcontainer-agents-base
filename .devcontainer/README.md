# Devcontainer

Node 22 with Claude Code, Codex and the GitHub CLI. Each tool keeps its login in a volume of its own per container: logins survive rebuilds and aren't shared with your other devcontainers.

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
3. Log in to the agents: run `claude`, and `codex` if you use it.
4. Edit `AGENTS.md` (`CLAUDE.md` just imports it) with your project's own rules.

## Optional: let agents use Chrome on your host

If Chrome is installed on your host (macOS or Linux) and you want agents in the container to browse, test pages or take screenshots in a real browser, ask your agent:

> Add the `chrome-mcp` feature from https://github.com/nevva/devcontainer-features to this devcontainer, following `src/chrome-mcp/NOTES.md`.

It starts a separate agent Chrome on the host, shared by all your containers. Log in to the sites the agent needs in that window once. Works with Claude Code (and Copilot CLI), not Codex.

## Good to know

- The token can only reach this repo: code and pull requests, for 90 days. Add `workflows=write` to the link if you will edit `.github/workflows`. When it expires, the steps show up again; make a new token and log in again.
- git authenticates to github.com only through `gh` (set in `.git/config` by `post-create.sh`), so the host credentials VS Code forwards aren't used.
- If you delete a container's volumes, you have to log in again.
