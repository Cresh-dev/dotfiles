---
paths:
  - "**/*.{js,jsx,mjs,cjs,ts,tsx}"
  - "**/package.json"
  - "**/tsconfig*.json"
---

# Regole JavaScript / TypeScript (Node, React)

## Strumenti e dipendenze
- Usa il package manager indicato dal lockfile: `package-lock.json` → npm, `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn. Non mischiarli e non cancellare il lockfile.
- Versione di Node: se esiste `.node-version` o `.nvmrc`, rispettala; se non c'è, proponi di aggiungerla.
- Installazione riproducibile (CI, clone pulito): `npm ci` invece di `npm install`. Spiegami la differenza la prima volta.
- Prima di aggiungere un pacchetto: a cosa serve, quanto pesa, se è mantenuto, se basta un'API nativa (`fetch`, `structuredClone`, `Intl`, `crypto.randomUUID()`...).
- Dopo aver aggiunto dipendenze, `npm audit` e segnalami le vulnerabilità alte o critiche.

## Codice
- Nei progetti TypeScript: `strict: true`, niente `any` (usa `unknown` più un controllo del tipo), niente `@ts-ignore` senza un commento che spieghi il perché.
- ES modules (`import`/`export`), `const` di default, `let` solo se la variabile cambia, mai `var`.
- `async`/`await` con gestione degli errori esplicita: nessuna Promise lasciata senza `await` o `.catch`.
- Usa la configurazione ESLint/Prettier del progetto; se non c'è, non introdurne una senza chiedere.

## React
- Componenti funzione e hook. Liste con `key` stabile (un id, mai l'indice se l'ordine può cambiare).
- `useEffect` solo per sincronizzarsi con sistemi esterni; i valori derivati calcolali durante il render. Spiegami il perché la prima volta.
- Mai `dangerouslySetInnerHTML` con contenuto non sanificato (rischio XSS).

## Backend Node (Express e simili)
- Valida ogni input (body, query, params), per esempio con uno schema (`zod`).
- Configurazione e segreti da variabili d'ambiente; il server non parte se manca una variabile obbligatoria.
- Errori: middleware centralizzato; mai restituire stack trace al client in produzione.
- Password solo con hash dedicati (`bcrypt`/`argon2`), mai in chiaro o con hash generici come SHA-256.

## Verifica
- Dopo ogni modifica esegui gli script del progetto, se esistono: `lint`, `typecheck` (o `tsc --noEmit`), `test` (Vitest/Jest), `build`.
