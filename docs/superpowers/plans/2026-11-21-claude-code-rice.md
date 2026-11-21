# Claude Code "rice" Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Statusline nerd con palette ANSI, tema `dark-ansi`, output style `Cresh`, spinner italiani, plugin ripuliti, rule Kubernetes, tutto nei dotfiles.

**Architecture:** Solo file standard di Claude Code nel pacchetto Stow `claude/`. La statusline è un unico script bash testato da uno script di test fuori dai pacchetti Stow (`tests/`). Le impostazioni vivono in `claude/.claude/settings.json`.

**Tech Stack:** bash, jq (`/usr/bin/jq`), shellcheck, GNU Stow, CLI `claude`.

**Spec:** `docs/superpowers/specs/2026-11-21-claude-code-rice-design.md`

## Global Constraints
- Colori solo ANSI 0–15 (`\e[3Nm`, `\e[90m` per il grigio 8): niente hex/truecolor.
- Testi dell'interfaccia in italiano; codice e commenti in inglese.
- Nessun dato personale nei file tracciati (repo pubblico).
- `claude/.claude/settings.json` e `~/.claude/*` non sono scrivibili in sandbox: modifica con Edit (richiede permesso); `stow` fuori sandbox con conferma.
- Statusline: una sola invocazione di `jq`, nessun `memory_pressure`, tempo < 100 ms.
- Commit su `master`, Conventional Commits, nessuna attribuzione AI. Niente push senza ok.
- `tests/` e `docs/` stanno alla radice: non sono in `MAC_PACKAGES`, quindi Stow li ignora.

## Review Focus
- Statusline con `rate_limits` assente → il segmento `5h` scompare, nessun `null` stampato.
- Statusline fuori da git, o con `current_dir` vuoto → nessun errore, niente segmento branch.
- Percentuali decimali (`38.7`) o assenti → troncate a intero / 0, niente errore aritmetico di bash.
- Branch "detached HEAD" (`git branch --show-current` vuoto) → mostra lo short SHA.
- `settings.json` non valido dopo le modifiche → Claude Code ignorerebbe tutte le impostazioni: validare con `jq` a ogni task.

---

### Task 1: Statusline nerd

**Files:**
- Modify: `claude/.claude/statusline.sh` (riscrittura)
- Create: `tests/statusline_test.sh`

**Interfaces:**
- Consumes: JSON di Claude Code su stdin (`.workspace.current_dir`, `.cwd`, `.model.display_name`, `.context_window.used_percentage`, `.rate_limits.five_hour.used_percentage`).
- Produces: una riga su stdout. Env di test `STATUSLINE_NO_RAM=1` disattiva il segmento RAM (rende l'output deterministico).

- [ ] **Step 1: Scrivi il test** `tests/statusline_test.sh` (bash, `set -euo pipefail`). Il test esegue lo script con JSON finti, rimuove le sequenze ANSI (`sed $'s/\e\\[[0-9;]*m//g'`) e confronta. Casi e aspettative:
  - `full`: dir = repo temporaneo git (`mktemp -d`, `git init -b main`, un commit, poi un file tracciato modificato), modello `Opus 5.5`, contesto `38.7`, rate `22.2` → output contiene ` <nome-dir>`, ` main*`, `󰚩 Opus 5.5`, `▰▰▰▱▱▱▱▱ 38%`, `󱐋 5h 22%`.
  - `no-rate`: senza `rate_limits` → nessuna occorrenza di `5h` né `null`.
  - `no-git`: dir = `mktemp -d` non git → nessun ``.
  - `empty`: input `{}` → exit 0, contiene `0%`.
  - `detached`: repo in detached HEAD → contiene lo short SHA (`git rev-parse --short HEAD`).
  - `colors`: l'output grezzo non contiene `38;2;` né `38;5;` (niente truecolor/256).
  - `speed`: caso `full` in meno di 100 ms (`date +%s%N` non esiste su BSD: usa `perl -MTime::HiRes=time` o `python3 -c 'import time'`).
  Stampa `PASS <caso>` / `FAIL <caso>: <atteso> vs <ottenuto>`; exit 1 se un caso fallisce.

- [ ] **Step 2: Esegui il test.** Run: `STATUSLINE_NO_RAM=1 bash tests/statusline_test.sh`. Atteso: FAIL su `full` (icone e barra `▰▱` mancanti nello script attuale).

- [ ] **Step 3: Riscrivi `claude/.claude/statusline.sh`** secondo la tabella §1 della spec: separatore `│` in grigio 8; barra a 8 celle `▰`/`▱` (celle piene = `pct * 8 / 100`); soglie contesto 60/80, rate 70/90, RAM pressure 2/4; una sola chiamata `jq -r` che emette i campi separati da tab (`@tsv`) letti con `IFS=$'\t' read -r`; percentuali troncate con `${x%%.*}` e default `0`; detached HEAD → `git rev-parse --short HEAD`; segmento RAM saltato se `STATUSLINE_NO_RAM=1`.

- [ ] **Step 4: Verifica.** Run: `STATUSLINE_NO_RAM=1 bash tests/statusline_test.sh && shellcheck claude/.claude/statusline.sh tests/statusline_test.sh`. Atteso: tutti `PASS`, shellcheck senza output. Poi un'esecuzione reale con RAM: `echo '{"model":{"display_name":"Opus 5.5"},"context_window":{"used_percentage":12}}' | claude/.claude/statusline.sh` → riga con `󰍛 <n>%`.

- [ ] **Step 5: Commit.** `git add claude/.claude/statusline.sh tests/statusline_test.sh` → `feat(claude): nerd status line with ANSI palette and 5h rate limit`

### Task 2: Output style `Cresh` e pulizia plugin

**Files:**
- Create: `claude/.claude/output-styles/cresh.md`
- Modify: `claude/.claude/settings.json` (`outputStyle`, `enabledPlugins`)

**Interfaces:**
- Produces: output style con nome `Cresh`, referenziato da `"outputStyle": "Cresh"`.

- [ ] **Step 1: Scrivi `cresh.md`.** Frontmatter: `name: Cresh`, `description: Italiano, asciutto, insight minimal stile terminale`, `keep-coding-instructions: true`. Corpo (in italiano, < 40 righe): tono diretto e senza riempitivi; insight solo quando c'è qualcosa di specifico da imparare; formato esatto del blocco:
  ```
  `── insight ─────────────────────────────`
  • …
  `────────────────────────────────────────`
  ```
  Non ripetere le regole di "Insegnami" del CLAUDE.md (cosa insegnare): qui solo il *come*.
- [ ] **Step 2: Modifica `settings.json`.** Aggiungi `"outputStyle": "Cresh"`; rimuovi da `enabledPlugins` `explanatory-output-style@claude-plugins-official` e le 9 voci `*@synced`.
- [ ] **Step 3: Disinstalla il plugin.** Run (fuori sandbox, con conferma): `claude plugin uninstall explanatory-output-style@claude-plugins-official`.
- [ ] **Step 4: Applica i symlink.** Run (fuori sandbox, con conferma, dalla radice del repo): `stow --restow claude`. Atteso: `~/.claude/output-styles/cresh.md` è un symlink al repo (`ls -l`).
- [ ] **Step 5: Verifica.** `jq . claude/.claude/settings.json >/dev/null` (exit 0); `claude plugin list` non mostra `explanatory-output-style`. In una nuova sessione `/output-style` elenca `Cresh` come attivo. Se le voci `@synced` ricompaiono in `settings.json`, annotalo per il Task 4.
- [ ] **Step 6: Commit.** `git add claude/.claude/output-styles/cresh.md claude/.claude/settings.json` → `feat(claude): add Cresh output style and prune unused plugins`

### Task 3: Tema e spinner

**Files:**
- Modify: `claude/.claude/settings.json` (`theme`, `spinnerVerbs`, `spinnerTipsEnabled`)

- [ ] **Step 1: Modifica `settings.json`.** `"theme": "dark-ansi"`; `"spinnerTipsEnabled": false`; `"spinnerVerbs": {"mode": "replace", "verbs": [...]}` con 20–30 verbi italiani al gerundio, ognuno sotto i 40 caratteri, a tema nerd/unix (esempi dalla spec: "Ricompilando il kernel dei pensieri", "Facendo grep nell'universo", "Risolvendo le dipendenze", "Facendo rebase della realtà", "Sfogliando le man page").
- [ ] **Step 2: Verifica.** `jq -e '.spinnerVerbs.mode == "replace" and (.spinnerVerbs.verbs | length >= 20) and all(.spinnerVerbs.verbs[]; length < 40)' claude/.claude/settings.json` → `true`. In `/config` il tema risulta "Dark mode (ANSI colors only)"; se `dark-ansi` non è accettato, usa `"dark"` e annotalo nel README.
- [ ] **Step 3: Commit.** `git add claude/.claude/settings.json` → `feat(claude): ANSI theme and Italian nerd spinner verbs`

### Task 4: Rule Kubernetes, gitignore, README

**Files:**
- Create: `claude/.claude/rules/kubernetes.md`
- Modify: `.gitignore`, `README.md` (sezione `claude`, righe 16–24)

- [ ] **Step 1: Scrivi `kubernetes.md`** con lo stesso stile di `rules/docker.md` (frontmatter `paths`, titolo, elenchi brevi, "spiegami la prima volta"). `paths`: `**/k8s/**/*.{yaml,yml}`, `**/manifests/**/*.{yaml,yml}`, `**/kustomization.{yaml,yml}`, `**/Chart.yaml`, `**/values*.{yaml,yml}`. Contenuto dalla spec §6.
- [ ] **Step 2: `.gitignore`:** aggiungi `**/.cc-writes/`.
- [ ] **Step 3: README:** nella riga del pacchetto `claude` aggiungi `output-styles/`; un paragrafo breve su statusline (segmenti, palette ANSI, `tests/statusline_test.sh`), tema `dark-ansi`, output style `Cresh`, rule k8s; nota che i file nuovi nel pacchetto richiedono `stow --restow claude`; eventuale nota sulle voci `@synced` (vedi Task 2).
- [ ] **Step 4: Stow e verifica.** `stow --restow claude` (fuori sandbox, conferma) → `ls -l ~/.claude/rules/kubernetes.md` è un symlink; `git status --short` non mostra `.cc-writes`.
- [ ] **Step 5: Commit.** Due commit: `feat(claude): add Kubernetes manifest rules` (rule) e `docs: document Claude Code look and layout` (README + `.gitignore` + spec + piano in `docs/superpowers/`).
