# PoC 04 – Helm

Baut auf [PoC 03](../poc-03-gke/README.md) auf: die Chat-App aus
[PoC 01](../poc-01-spring-ai/README.md) wird als **Helm-Chart** verpackt und auf
den GKE-Cluster deployt. Werte werden parametrisiert, Upgrade und Rollback
werden geübt.

## Lernziele

* Helm installieren und ein Chart verstehen
* Anwendung als Chart verpacken und Werte parametrisieren (`values.yaml`)
* Chart installieren, upgraden und ein Rollback durchführen

## Voraussetzungen

* PoC 02/03 abgeschlossen (Projekt, Artifact Registry, GKE-Cluster, `kubectl`
  gegen den Cluster konfiguriert)
* `helm` installiert (`brew install helm`)
* Zum echten Deploy: `docker` + Zugriff auf die Artifact Registry und ein
  gültiger `OPENAI_API_KEY`

## Konfiguration

Parameter in [`config.env`](./config.env) anpassen – müssen zu PoC 02/03 passen:

| Variable       | Beispiel            | Bedeutung                                 |
|----------------|---------------------|-------------------------------------------|
| `PROJECT_ID`   | `gitops-lab-000000` | Projekt aus PoC 02                        |
| `REGION`       | `europe-west6`      | Region                                    |
| `AR_REPO`      | `gitops-lab-docker` | Artifact-Registry-Docker-Repo (PoC 02)    |
| `NAMESPACE`    | `poc-01-spring-ai`  | Namespace (PoC 03)                        |
| `APP_DIR`      | `../poc-01-spring-ai` | Quellverzeichnis der App                |
| `IMAGE_NAME`   | `poc-01-spring-ai`  | Image-Name                                |
| `IMAGE_TAG`    | `0.1.0`             | Image-/App-Version                        |
| `RELEASE_NAME` | `poc-01-spring-ai`  | Helm-Release-Name                         |
| `CHART_DIR`    | `chart`             | Chart-Verzeichnis                         |

Der `OPENAI_API_KEY` wird **nicht** in `config.env` eingetragen, sondern als
Umgebungsvariable exportiert:

```bash
export OPENAI_API_KEY=sk-...
```

## Schnellstart

```bash
cd poc-04-helm

./scripts/01-lint.sh              # Chart validieren (kein Cluster nötig)
./scripts/00-build-push.sh        # App-Image bauen + in Artifact Registry pushen
./scripts/02-install.sh           # Chart auf GKE installieren
./scripts/05-verify.sh            # Pods/Service prüfen
./scripts/03-upgrade.sh 2         # Upgrade: replicaCount=2 → neue Revision
./scripts/04-rollback.sh          # Rollback auf vorherige Revision
```

Alle Skripte sind **idempotent**. Aufräumen: `./scripts/99-teardown.sh`.

## Nur lokal das Chart üben (ohne GKE/Registry)

`helm lint` und `helm template` brauchen weder Cluster noch Image:

```bash
./scripts/01-lint.sh
helm template poc-01-spring-ai chart \
  --set image.repository=demo --set image.tag=dev \
  --set openai.apiKey=dummy
```

## Was die Skripte tun

| Skript               | Aktion                                                            |
|----------------------|------------------------------------------------------------------|
| `00-build-push.sh`   | `docker build` (Dockerfile aus PoC 01) + Push in Artifact Registry |
| `01-lint.sh`         | `helm lint` + `helm template` (Render-Test)                      |
| `02-install.sh`      | `helm upgrade --install` inkl. Secret aus `OPENAI_API_KEY`       |
| `03-upgrade.sh`      | `helm upgrade` mit neuem `replicaCount` (neue Revision)          |
| `04-rollback.sh`     | `helm rollback` auf eine frühere Revision                        |
| `05-verify.sh`       | `helm list/history`, Rollout-Status, Pods, Service               |
| `99-teardown.sh`     | `helm uninstall`; Namespace nur nach Rückfrage                   |

## Das Chart (`chart/`)

```text
chart/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml     # Spring-Boot-Container, Port 8080
    ├── service.yaml        # ClusterIP :80 → 8080
    ├── secret.yaml         # OPENAI_API_KEY (oder existingSecret)
    ├── configmap.yaml      # App-Chat-Limits als Env
    ├── serviceaccount.yaml
    └── NOTES.txt
```

Wichtige `values.yaml`-Parameter:

* `image.repository`, `image.tag` – von den Skripten aus `config.env` gesetzt
* `replicaCount` – Zahl der Pods (Upgrade-Demo)
* `openai.apiKey` / `openai.existingSecret` – Zugangsdaten für die App
* `config.*` – Chat-Limits (`APP_CHAT_MAX_TOKENS` etc.), gemappt auf
  Spring-Properties via Relaxed Binding
* `resources`, `probes` – Ressourcen-Limits und Health-Checks (auf `/`)

## Ergebnis / Definition of Done

* `helm list -n <NAMESPACE>` zeigt das Release als `deployed`
* Pods sind `Running`/`Ready`; die App ist per Port-Forward erreichbar
* Ein Upgrade erzeugt eine neue Revision, `helm rollback` stellt die alte wieder her

Basis für **PoC 05 – Argo CD** (dasselbe Chart wird dort per GitOps synchronisiert).

## Kostenhinweis

Läuft auf dem GKE-Cluster aus PoC 03 – nach dem Üben mit `99-teardown.sh` das
Release entfernen und ggf. den Cluster (PoC 03) löschen.
