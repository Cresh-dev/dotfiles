---
name: new-project
description: Scaffold a new Python or Node/TypeScript project following Alessio's conventions.
disable-model-invocation: true
argument-hint: "<python|node> <name> [parent-dir]"
---

Create a project from `$ARGUMENTS` (type, name, optional parent dir; default parent `~/Development`). Show the plan (path, files, versions) and wait for OK before creating anything.

Rules:
- Never inside `~/Documents` or `~/Desktop`: they sync to iCloud, which breaks `.venv`/`node_modules`. If asked, warn and propose `~/Development`.
- Refuse if the target exists and is not empty, or if it sits inside another git repo (unless the user confirms).
- Pin the runtime with mise in the project: `mise use python@3.14` or `mise use node@lts` (creates `mise.toml`).
- Code, file names and comments in English. Ask before adding any dependency beyond the minimal set below, saying what it is for.

Python:
- If `uv` exists: `uv init --app`, then `uv venv --python "$(mise which python)"`, dev deps `uv add --dev pytest ruff`. Otherwise: `python -m venv .venv` with mise's Python, `requirements.txt` + `requirements-dev.txt` (pytest, ruff), and tell the user uv is the preferred tool (`mise use -g uv`).
- Layout: `src/<package>/__init__.py`, `tests/test_smoke.py` (one passing test).

Node/TypeScript:
- `npm init -y`, `.node-version` matching mise, TypeScript with `"strict": true`, ES modules (`"type": "module"`), scripts `build`, `typecheck`, `test` (Vitest). No ESLint/Prettier unless asked.
- `src/index.ts`, `tests/index.test.ts` (one passing test).

Both:
- `.gitignore` (`.venv/`, `node_modules/`, `dist/`, `.env`, `.DS_Store`, caches), `.env.example` with placeholder values, `README.md` (what it is, install, run, test).
- `git init -b main`, first commit `chore: initial project scaffold` (no AI attribution). Don't create a remote or push.
- Verify: run the test command and the linter/typecheck; report the output.

Reply in Italian: tree of created files, commands to run, and one or two lines on why this layout.
