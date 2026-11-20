---
paths:
  - "**/.github/workflows/*.{yml,yaml}"
  - "**/.github/dependabot.yml"
---

# Regole GitHub Actions

- Permessi minimi: dichiara `permissions:` a livello di workflow (default `contents: read`) e aggiungi solo quelli necessari al singolo job (es. `pages: write` per il deploy su GitHub Pages). Spiegami perché la prima volta.
- Azioni di terze parti fissate allo **SHA completo del commit**, con la versione in commento: `uses: owner/action@<sha> # v4.2.0`. Un tag come `@v4` può essere spostato da chi controlla l'azione (attacco supply chain).
- Mai stampare segreti nei log; passali come `env:` al singolo step, non a tutto il workflow.
- Attenzione a `pull_request_target` e all'uso diretto di `${{ github.event.* }}` dentro `run:` (rischio di iniezione di comandi): passa questi valori tramite variabili d'ambiente.
- Usa la cache del package manager (`actions/setup-node` con `cache: npm`, `actions/setup-python` con `cache: pip`) e versioni del runtime coerenti con il progetto (`.node-version`, `.python-version`).
- `concurrency` per i deploy, così due esecuzioni non si sovrappongono.
- Proponi Dependabot (`.github/dependabot.yml`) per aggiornare dipendenze e azioni, se il repo non lo ha.
