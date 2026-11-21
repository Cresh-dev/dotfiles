# Claude Code "rice": estetica e ordine — design

Data: 2026-11-21 · Stato: bozza da approvare

## Intento
Rendere Claude Code coerente con il resto del setup (Ghostty con tema Apprentice, JetBrainsMono Nerd Font, Starship): estetica **minimal, particolare, stile unixporn/nerd**. Insieme, una configurazione ordinata: tenere solo ciò che serve, togliere il rumore, tutto versionato in `~/dotfiles` via Stow.

Uso tipico: studio, siti (Jekyll, Quartz), dotfiles, sperimentazione con Docker e Kubernetes, informatica in generale.

## Obiettivi
- Statusline nerd su una riga che riusa la palette del terminale.
- Tema dell'interfaccia allineato ai colori del terminale.
- Output style personale in italiano, al posto del plugin generico `explanatory-output-style`.
- Spinner verbs personalizzati, in italiano, a tema nerd.
- Elenco plugin pulito: ogni plugin attivo ha un motivo.
- Una rule per i manifest Kubernetes, coerente con `docker.md`.
- README dei dotfiles aggiornato.

## Non-obiettivi
- Mod/plugin TypeScript personale (approccio B): magari più avanti, sopra questo.
- Strumenti npm della community per la statusline.
- Keybindings custom: si aggiungono solo quando nasce un bisogno concreto.
- Toccare permessi, sandbox, hook di sicurezza esistenti (oltre al minimo indicato sotto).

## Anti-obiettivi (sarebbe un fallimento anche se funziona)
- Una statusline "albero di Natale": troppi segmenti, troppi colori, stile powerline.
- Colori hex fissi che non seguono il tema di Ghostty.
- Una statusline lenta: deve restare nell'ordine dei millisecondi (niente `memory_pressure`, una sola chiamata `jq`).
- Mischiare italiano e inglese nei messaggi dell'interfaccia.

## Vincoli
- 8 GB di RAM: niente processi persistenti in più, nessun plugin pesante.
- Dotfiles **pubblici**: nessun dato personale nei file tracciati.
- In sandbox la scrittura in `~/.claude/*` e su `dotfiles/claude/.claude/settings.json` è negata: i file si modificano nel repo, e il comando `stow` va lanciato fuori sandbox con conferma.
- `jq` di macOS (`/usr/bin/jq`), bash di sistema/Homebrew; utility BSD.

## Approcci considerati
| Approccio | Pro | Contro |
|---|---|---|
| **A. File standard di Claude Code nei dotfiles** *(scelto)* | Zero dipendenze, leggibile, si studia facilmente, si integra con Stow | Non tocca gli elementi interni della UI oltre al tema |
| B. Mod personale (plugin TypeScript) | Massimo controllo sulla UI | API giovane, fragile, da mantenere |
| C. `ccstatusline` / `claude-powerline` (npm) | Pronti, ricchi di widget | Stile non minimal, dipendenza esterna eseguita a ogni refresh, poco "tuo" |

Scelto **A** da Alessio. B resta possibile in futuro senza buttare via niente.

## Design

### 1. Statusline (`claude/.claude/statusline.sh`, riscrittura)
Una riga, separatore `│` in grigio scuro, icone Nerd Font. Solo colori **ANSI 0–15**, così segue il tema di Ghostty.

```
 dotfiles   master* │ 󰚩 Opus 5.5 │ ▰▰▰▱▱▱▱▱ 38% │ 󱐋 5h 22% │ 󰍛 61%
```

| Segmento | Fonte | Colore |
|---|---|---|
| ` <cartella>` | `.workspace.current_dir` | blu (4) |
| ` <branch>` + `*` se ci sono modifiche tracciate | `git` | magenta (5), `*` giallo (3) |
| `󰚩 <modello>` | `.model.display_name` | grigio (8) |
| barra contesto a 8 celle `▰▱` + % | `.context_window.used_percentage` | grigio → giallo ≥60 → rosso ≥80 |
| `󱐋 5h <n>%` (solo se il campo c'è) | `.rate_limits.five_hour.used_percentage` | grigio → giallo ≥70 → rosso ≥90 |
| `󰍛 <n>%` RAM libera | `sysctl kern.memorystatus_level` / `_vm_pressure_level` | grigio → giallo (2) → rosso (4) |

- Una sola chiamata `jq` che estrae tutti i campi (oggi sono 3).
- Fuori da un repo git il segmento branch sparisce. Senza `rate_limits` (campo assente fino alla prima risposta) il segmento 5h sparisce.
- Resta la logica attuale: `git status --untracked-files=no` per la velocità.

### 2. Tema dell'interfaccia
`"theme": "dark-ansi"` in `settings.json`: usa i 16 colori ANSI del terminale, quindi Apprentice. Se la build non lo supporta, ripiego su `"dark"`. Da verificare in `/config`.

### 3. Output style `Cresh` (`claude/.claude/output-styles/cresh.md`, nuovo)
- Frontmatter: `name: Cresh`, descrizione, `keep-coding-instructions: true` (conserva le istruzioni di ingegneria del software).
- Contenuto: tono asciutto e diretto in italiano; blocchi didattici in un formato minimal-nerd, ad esempio:
  ```
  ── insight ─────────────────────────────
  • punto 1
  • punto 2
  ────────────────────────────────────────
  ```
  Insight solo quando c'è qualcosa di specifico da imparare, non a ogni risposta.
- Divisione dei compiti: **CLAUDE.md** dice *cosa* insegnare (sezione "Insegnami", invariata), l'**output style** dice *come* presentarlo. Niente istruzioni duplicate.
- `"outputStyle": "Cresh"` in `settings.json`.

### 4. Spinner (`settings.json`)
- `spinnerVerbs` con `mode: "replace"`: solo verbi italiani, ~25, a tema nerd/unix (es. "Ricompilando il kernel dei pensieri", "Facendo grep nell'universo", "Risolvendo le dipendenze", "Facendo rebase della realtà", "Sfogliando le man page"). Con `replace` niente mix italiano/inglese.
- `spinnerTipsEnabled: false`: meno rumore, più minimal.

### 5. Plugin (`settings.json` + `claude plugin`)
| Plugin | Decisione | Motivo |
|---|---|---|
| superpowers | tieni | flusso brainstorm → piano → esecuzione |
| pyright-lsp, typescript-lsp | tieni | Python, Quartz (TS) |
| clangd-lsp | tieni | Secure Programming Lab (C) |
| security-guidance | tieni | sicurezza |
| claude-md-management | tieni | manutenzione CLAUDE.md |
| context7 (MCP) | tieni | documentazione aggiornata |
| explanatory-output-style | **disinstalla** | sostituito da `Cresh` |
| 9 voci `*@synced` disattivate | **rimuovi da `enabledPlugins`** | rumore; se la sync di claude.ai le ricrea, le lascio e lo annoto nel README |

Nessun plugin nuovo: per l'uso descritto quelli presenti bastano; aggiungerne costerebbe contesto senza un bisogno concreto.

### 6. Rule Kubernetes (`claude/.claude/rules/kubernetes.md`, nuova)
`paths` sui manifest (`**/k8s/**/*.{yaml,yml}`, `**/manifests/**`, `**/kustomization.{yaml,yml}`, `**/Chart.yaml`, `**/values*.yaml`). Contenuto: `resources.requests/limits` sempre, immagini con tag preciso e `linux/arm64`, `securityContext` (non root, `readOnlyRootFilesystem`), namespace dedicati, minikube con limiti e `minikube stop` a fine uso, spiegare `kubectl apply` vs `create`.

### 7. Pulizia repo
- `.gitignore`: aggiungere `.claude/.cc-writes/` e `**/.cc-writes/` (file di lavoro di Claude Code finiti nel repo, oggi non tracciati).
- README: sezione Claude Code aggiornata (statusline, output style, tema, rule k8s, nota su stow per i file nuovi).

### 8. Applicazione
- Modifiche nei file del repo; i file nuovi (`output-styles/cresh.md`, `rules/kubernetes.md`) richiedono `stow` per creare i symlink: comando lanciato fuori sandbox, con conferma.
- Commit piccoli su `master`, come la storia del repo (un commit per area: statusline, output style + plugin, spinner + tema, rule k8s, docs). Push solo dopo il tuo ok.

## Verifica
- `shellcheck statusline.sh`; esecuzione con un JSON finto (con e senza `rate_limits`, dentro e fuori da git) e misura del tempo (`time`).
- `jq . settings.json` per la validità; controllo che Claude Code carichi senza errori (`/config`, `/output-style`, `/doctor`).
- `claude plugin list` dopo la pulizia.

## Lasciato a chi implementa
- La lista esatta degli spinner verbs (tono: ironico, nerd, breve).
- Le icone Nerd Font precise, purché leggibili a 14 pt.
- Il testo dell'output style, entro le regole sopra.
