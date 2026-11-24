# Agent instructions

## Language

- Always respond in English, even when the user writes in another language.
- Write everything in the code in English: identifiers, comments, commit messages and docs.

## Code style

- Avoid unnecessary comments. Only comment what the code can't express itself, such as why something is done or non-obvious constraints. Don't write comments that restate what the code does.

## GitHub

- `gh` holds the GitHub login for this container (a fine-grained token for this repository only, or an OAuth login if `GH_LOGIN=oauth`); git pushes through it. Push with `git`, open pull requests with `gh pr create`.
- If `gh` reports no login, or a push or API call is refused (401/403), stop and ask the person to log in: `bash .devcontainer/welcome.sh` prints the steps. Don't look for other credentials.
