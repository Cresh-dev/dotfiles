---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
---

# Regole Python

## Ambiente e dipendenze
- **Mai** installare pacchetti nel Python di sistema o di Homebrew: ogni progetto ha il suo ambiente virtuale (`.venv` nella cartella del progetto, in `.gitignore`). Spiegami perché la prima volta.
- Strumento preferito: **uv** (`uv venv`, `uv add <pacchetto>`, `uv run <comando>`): gestisce ambiente, dipendenze e lockfile ed è molto veloce. Se manca, proponi `brew install uv`.
- Se il progetto usa già `requirements.txt` o un altro strumento (pip, Poetry), rispettalo e segnalami solo se conviene migrare.
- Dipendenze dichiarate in `pyproject.toml` quando possibile; versioni fissate nel lockfile.

## Codice
- Type hints su funzioni e metodi pubblici. Se c'è un type checker configurato (mypy, pyright), eseguilo.
- Formattazione e lint con **ruff** (`ruff format`, `ruff check`), se il progetto non ha già altro.
- Percorsi con `pathlib.Path`, non concatenando stringhe. File aperti con `with`.
- Eccezioni specifiche: mai `except:` nudo o `except Exception: pass` che nasconde gli errori.
- `logging` invece di `print` per tutto ciò che non è output per l'utente.
- Configurazione da variabili d'ambiente; segreti mai nel codice.
- Sicurezza: niente `eval`/`exec` su input, niente `pickle` su dati non fidati, `subprocess` con lista di argomenti e senza `shell=True`, query SQL parametrizzate.

## Test
- **pytest**. Test in `tests/`, file `test_*.py`. Quando correggi un bug, prima scrivi il test che fallisce.
- Esegui con `uv run pytest` (o `pytest` nell'ambiente attivo).
