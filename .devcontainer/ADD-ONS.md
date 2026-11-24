# Add-ons: instructions for the agent

The person pointed you at this file to add optional features to this devcontainer. Work through these steps in order.

1. **Ask** which add-ons they want. Show the table below and ask the questions listed for each add-on they pick. Ask everything in one round, and don't edit anything before they answer.
2. **Apply** each chosen add-on to `.devcontainer/devcontainer.json`, keeping its existing entries and comments. Keep any `.devcontainer/README.md` sections that describe the change up to date.
3. **Teach** later agents: add the add-on's "For `AGENTS.md`" block to `AGENTS.md` under a `## Tools in this devcontainer` heading. Create the heading if it isn't there, and don't add the same block twice.
4. **Hand over:** list the steps only the person can do (rebuild, host setup, logins), then stop. You can't rebuild the container from inside it. When several add-ons are chosen, make all the `devcontainer.json` changes first, so one rebuild covers them all.

To remove an add-on, undo its changes in `devcontainer.json` and delete its block from `AGENTS.md`.

| Add-on | What it gives the agents | Works with |
|---|---|---|
| [`chrome-mcp`](#chrome-mcp) | Drive a real Chrome on the host: browse, test pages in the dev server, take screenshots | Claude Code, Copilot CLI (not Codex) |
| [`korp`](#korp) | Korp: code index, tasks, goals and decisions, validation, a browser UI and a dashboard, as CLI, MCP, skills and hooks | Claude Code, Copilot CLI, Codex (skills only) |

---

## chrome-mcp

Source: <https://github.com/nevva/devcontainer-features/tree/main/src/chrome-mcp> (`NOTES.md` there is the full reference; read it if something below doesn't fit).

### Ask

- Host OS: macOS or Linux? Windows hosts aren't supported. If they're on Windows, say so and skip this add-on.
- Container runtime: Docker Desktop, Rancher Desktop, or plain Docker Engine on Linux?
- Ports of dev servers in the container that the agent should open in Chrome, for example `3000`. Ports are optional.
- VS Code, or the devcontainer CLI only?

### Apply

```jsonc
"features": {
  // ...existing features
  "ghcr.io/nevva/devcontainer-features/chrome-mcp:1": {}
},
// Runs on the host each time the container opens: fetches start-agent-chrome once, then starts the agent Chrome.
"initializeCommand": "f=\"$HOME/.local/bin/start-agent-chrome\"; [ -x \"$f\" ] || { mkdir -p \"${f%/*}\" && curl -fsSLo \"$f\" https://raw.githubusercontent.com/nevva/devcontainer-features/main/host/start-agent-chrome.sh && chmod +x \"$f\"; }; \"$f\" || true"
```

- The image (`javascript-node`) already has Node, so the node feature isn't needed. If the image has been changed to one without Node, add `"ghcr.io/devcontainers/features/node:1": {}`.
- If `initializeCommand` already exists, join the two commands with `;`.
- On plain Docker Engine on Linux, add `"runArgs": ["--add-host=host.docker.internal:host-gateway"]` (or append it to the existing `runArgs`).
- For each dev server port: with VS Code, add it to `"forwardPorts"`; with the CLI only, add it to `"appPort"` and make sure the dev server listens on `0.0.0.0`.
- Don't use port `9333` or `9222` for dev servers: the agent Chrome and its tunnel use them.

### Hand over

- Rebuild the container. The agent Chrome window then opens on the host.
- In that window, log in to the sites the agent needs. Logins are kept and shared by every container on the host.
- Restart Claude Code (or run `/restart` in Copilot CLI) so it picks up the `chrome-devtools` MCP server.
- Warning: the agent can act as any account logged in to that Chrome. Use accounts you're fine with an agent using.

### For `AGENTS.md`

```markdown
### Browser (chrome-mcp)

- The `chrome-devtools` MCP server drives an agent Chrome on the host. Use it to open pages, check UI changes and take screenshots.
- Dev servers in the container: open them at `http://localhost:<port>`. That works only for ports listed in `forwardPorts`/`appPort` in `.devcontainer/devcontainer.json`, and with the CLI only the server must listen on `0.0.0.0`.
- The person's logins live in that Chrome. Don't log out, change account settings, or submit anything outward-facing without asking.
- Other containers share this Chrome. Open your own tab instead of taking over existing ones.
- If the MCP tools fail to connect, the agent Chrome was probably closed. Ask the person to run `~/.local/bin/start-agent-chrome` on the host (not in the container) and then reconnect with `/mcp` → `chrome-devtools`.
```

---

## korp

Source: `callide-se/korp` (private repo). The feature `ghcr.io/callide-se/korp/korp:0` is public: it installs the `korp` and `korp-daemon` binaries (linux x86_64/aarch64, glibc) and nothing else. Wiring Korp into the agents is a separate step: `korp init` plans the repo setup and `korp apply` writes it. `korp --help` and `korp init --help` are the reference.

Korp gives agents a code index (`code.scout`/`outline`/`read`), edits and validation through Korp, tasks, goals and decisions in a graph tracked under `korp/graph/`, a browser UI and a terminal dashboard (`korp tui`).

### Ask

- Binaries only, or also set up this repo for Korp (skills, MCP, hooks)?
- If setting up:
  - Which agents: `claude`, `codex`, `copilot` (all three are in this container)? Codex gets skills only, with no MCP server and no hooks.
  - `AGENTS.md`: let Korp **move** it to `.korp/instructions/AGENTS.md`, leaving a stub that sends agents to `korp session`, after which Korp serves the rules. Or **keep** it in place, with Korp only appending a short block.
  - Claude Code hooks: `inject` (default: the session start injects the Korp context, and prompt and stop hooks are added), `remind` (also a per-prompt "scout before grep" reminder), or `none`.
  - MCP profile: `minimal` (default: scout plus a gateway to every action), `full`, or `none`.
- Should the Korp browser UI (port 7777 in the container) be reachable from the host? VS Code, or the devcontainer CLI only?

### Apply

```jsonc
"features": {
  // ...existing features
  "ghcr.io/callide-se/korp/korp:0": {}
}
```

- UI port: with VS Code, add `7777` to `"forwardPorts"`. With the CLI only, add it to `"appPort"` and set `"KORP_UI_HOST": "0.0.0.0"` in `containerEnv`.
- Repo setup needs the binary, which arrives with the rebuild. If `command -v korp` fails, stop after the `devcontainer.json` change and tell the person to rebuild and then ask you to finish the korp setup in this file. Once `korp` is on PATH:
  1. Dry run: `korp init --sandbox none --agent <a> [--agent <b>]... --hooks <h> --mcp <m>`, plus `--keep-agent-file AGENTS.md` if they chose keep. Always pass `--sandbox none`: the default generates a second devcontainer. The dry run already writes `korp/graph/project.json`, which is meant to be committed.
  2. Show the person the plan's `files` (path + action) and `defaults`, and get a yes.
  3. `korp apply <planHash>` with exactly the same flags.
- If the plan moved `AGENTS.md`, the repository's rules now live in `.korp/instructions/AGENTS.md`. Add the "For `AGENTS.md`" blocks of this and any other add-on there, not to the stub.

### Hand over

- Rebuild the container, if not done yet.
- Restart the agents so they pick up the skills, `.mcp.json` and hooks.
- `korp tui` opens the dashboard and `korp ui` the browser side.
- The `:0` tag follows new 0.x releases on rebuild. After an upgrade, rerun the same `korp init`/`korp apply` to refresh the files Korp wrote. It never touches files someone edited.

### For `AGENTS.md`

```markdown
### Korp

- `korp` is installed by the devcontainer feature `ghcr.io/callide-se/korp/korp:0`, and the repo setup is recorded in `.korp/setup.json`. Follow the korp block and skills for how to work.
- To change the setup, rerun `korp init --sandbox none ...` with the options wanted (`.korp/setup.json` shows what the last setup wrote), show the plan, then `korp apply <planHash>`. Never drop `--sandbox none`: this repo already has its devcontainer.
```
