---
paths:
  - "**/k8s/**/*.{yaml,yml}"
  - "**/manifests/**/*.{yaml,yml}"
  - "**/kustomization.{yaml,yml}"
  - "**/Chart.yaml"
  - "**/values*.{yaml,yml}"
---

# Regole Kubernetes (manifest, Kustomize, Helm)

## Risorse
- Ogni container ha `resources.requests` e `resources.limits` per CPU e memoria. Spiegami la differenza la prima volta: le `requests` servono allo scheduler per scegliere il nodo, i `limits` sono il tetto oltre il quale il container viene rallentato (CPU) o ucciso (memoria, OOMKilled).
- Cluster locale su 8 GB di RAM: tieni la somma dei `limits` sotto ~1,5 GB con minikube a 2 GB.

## Immagini
- Tag preciso (es. `nginx:1.27-alpine`), **mai `latest`**; `imagePullPolicy` coerente con il tag.
- Devono esistere per `linux/arm64`: se un'immagine è solo `amd64`, segnalamelo prima di usarla.

## Sicurezza
- `securityContext` sul pod e sul container: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true` dove possibile, `capabilities.drop: ["ALL"]`.
- Niente segreti in chiaro nei manifest o in `values.yaml`: usa `Secret` creati da riga di comando o da file non tracciati, e spiegami che un `Secret` è solo base64, non cifrato.
- `ServiceAccount` dedicato con RBAC minimo; `automountServiceAccountToken: false` se il pod non parla con l'API.

## Struttura
- Un `Namespace` dedicato per ogni esperimento, così si pulisce tutto con un solo `kubectl delete namespace`.
- Label standard `app.kubernetes.io/name`, `app.kubernetes.io/part-of`.
- `livenessProbe` e `readinessProbe` per i servizi HTTP.

## Comandi
- Preferisci `kubectl apply -f` (dichiarativo, idempotente) a `kubectl create`; spiegami la differenza la prima volta. Prima di applicare, `kubectl diff -f` per vedere cosa cambia.
- minikube: `minikube start --driver=docker --memory=2048 --cpus=2` e, a fine sessione, ricordami `minikube stop`. Con kind, ricordami `kind delete cluster` se il cluster non serve più (**chiedi conferma**).
