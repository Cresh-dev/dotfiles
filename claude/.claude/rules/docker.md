---
paths:
  - "**/Dockerfile"
  - "**/Dockerfile.*"
  - "**/*.dockerfile"
  - "**/.dockerignore"
  - "**/compose*.{yaml,yml}"
  - "**/docker-compose*.{yaml,yml}"
---

# Regole Docker e Compose

## Dockerfile
- Usa build **multi-stage**: uno stage per compilare/installare, uno finale minimale (es. `-slim`, `alpine` o `distroless`). Spiega cosa guadagno in dimensione e superficie d'attacco.
- Immagine base con tag preciso (es. `python:3.12-slim`), **mai `latest`**.
- Nell'immagine finale il processo gira come **utente non root** (`USER`).
- Ordina le istruzioni per sfruttare la cache: prima le dipendenze (es. `COPY requirements.txt` + install), poi il codice.
- Unisci i comandi `RUN` collegati e pulisci le cache del package manager nello stesso layer.
- Crea sempre un `.dockerignore` (almeno `.git`, `.env`, `node_modules`, `__pycache__`, file di build).
- Nessun segreto in `ARG`, `ENV` o file copiati: resterebbero nei layer dell'immagine. Per segreti in fase di build usa `RUN --mount=type=secret`.

## Architettura
- Sul Mac (M1) le immagini sono `linux/arm64`. Se l'immagine deve girare anche su server `amd64`, usa `docker buildx build --platform linux/amd64,linux/arm64`.
- Se un'immagine esterna esiste solo per `amd64`, segnalamelo prima di usarla (gira in emulazione, lenta).

## Compose
- Ogni servizio ha un limite di memoria (`mem_limit` o `deploy.resources.limits.memory`): con 8 GB di RAM totali, tieni la somma dei servizi sotto ~3 GB.
- Porte pubblicate solo su localhost quando non servono all'esterno: `"127.0.0.1:8080:8080"`.
- Variabili sensibili in un file `.env` non committato; committa un `.env.example` con valori finti.
- `healthcheck` per i servizi da cui ne dipendono altri, e `depends_on` con `condition: service_healthy`.

## Pulizia
- A fine sessione, se ho lasciato container o immagini inutili, proponi `docker system df` per vedere lo spazio usato e cosa eliminare, **senza cancellare nulla senza conferma**.
