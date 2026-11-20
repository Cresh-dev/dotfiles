---
paths:
  - "**/*.sh"
  - "**/*.bash"
  - "**/*.zsh"
  - "**/.zshrc"
  - "**/.zprofile"
---

# Regole per script shell

- Prima riga: `#!/usr/bin/env bash` (o `zsh` se servono funzioni specifiche di zsh). Subito dopo: `set -euo pipefail` e spiegami cosa fa ciascuna opzione la prima volta.
- Racchiudi sempre le variabili tra virgolette: `"$var"`, `"${array[@]}"`.
- Variabili locali nelle funzioni con `local`. Nomi delle costanti in MAIUSCOLO.
- Controlla le dipendenze all'inizio: `command -v jq >/dev/null || { echo "jq mancante: brew install jq" >&2; exit 1; }`.
- Messaggi di errore su stderr (`>&2`) ed exit code diverso da 0.
- Gli script devono funzionare su **macOS (BSD)**: niente `sed -i` senza argomento, `date -d`, `grep -P`, `readlink -f`. Se servono davvero le versioni GNU, usa `gsed`, `gdate` ecc. e dichiaralo.
- Se `shellcheck` è installato, eseguilo dopo ogni modifica e correggi gli avvisi; se non c'è, proponi `brew install shellcheck`.
- Script che cancellano o sovrascrivono file: aggiungi una conferma o un'opzione `--dry-run`.
