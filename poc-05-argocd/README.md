# PoC 05 – Argo CD

Baut auf [PoC 04](../poc-04-helm/README.md) auf: **dasselbe Helm-Chart** wird
jetzt nicht mehr manuell mit `helm install` deployt, sondern von **Argo CD** per
**GitOps** aus dem Git-Repository synchronisiert. Der gewünschte Zustand steht im
Git, Argo CD gleicht den Cluster kontinuierlich dagegen ab.

## Lernziele

* Argo CD im GKE-Cluster installieren und die UI/CLI bedienen
* Ein GitHub-Repository als Quelle anbinden
* Eine **Application** anlegen, die auf das Chart aus PoC 04 zeigt
* Manuell synchronisieren und anschließend **Auto-Sync** aktivieren

## Voraussetzungen

* PoC 02/03/04 abgeschlossen: Projekt, Artifact Registry, GKE-Cluster,
  `kubectl` gegen den Cluster konfiguriert, **Image bereits gepusht**
  (PoC 04 `00-build-push.sh`)
* Das Chart liegt im Git-Repo unter `poc-04-helm/chart` und ist **committed
  und gepusht** – Argo CD liest ausschließlich aus Git
* `kubectl`, `envsubst` (Teil von `gettext`), optional die `argocd`-CLI
  (`brew install argocd`)
* Gültiger `OPENAI_API_KEY` (als Umgebungsvariable exportiert)

## Konfiguration

Parameter in [`config.env`](./config.env) anpassen – müssen zu PoC 02/03/04
passen:

| Variable             | Beispiel                                   | Bedeutung                          |
|----------------------|--------------------------------------------|------------------------------------|
| `PROJECT_ID`         | `gitops-lab-000000`                        | Projekt aus PoC 02                 |
| `REGION`             | `europe-west6`                             | Region                             |
| `AR_REPO`            | `gitops-lab-docker`                        | Artifact-Registry-Repo (PoC 02)    |
| `NAMESPACE`          | `poc-01-spring-ai`                         | Ziel-Namespace der App             |
| `IMAGE_NAME`/`_TAG`  | `poc-01-spring-ai` / `0.1.0`               | Image aus PoC 04                   |
| `ARGOCD_NAMESPACE`   | `argocd`                                   | Namespace für Argo CD              |
| `ARGOCD_VERSION`     | `stable`                                   | Version des Install-Manifests      |
| `GIT_REPO_URL`       | `https://github.com/chevp/gitops-lab.git`  | Von Argo CD beobachtetes Repo      |
| `GIT_TARGET_REVISION`| `main`                                     | Branch/Tag/Commit                  |
| `CHART_PATH`         | `poc-04-helm/chart`                        | Chart-Pfad **im Repo**             |
| `APP_NAME`           | `poc-01-spring-ai`                         | Name der Argo-CD-Application       |
| `OPENAI_SECRET_NAME` | `poc-01-spring-ai-openai`                  | Secret für den OpenAI-Key          |

Der `OPENAI_API_KEY` gehört **nicht** ins Git. Er wird als Umgebungsvariable
exportiert und von `04-app-secret.sh` in ein Kubernetes-Secret geschrieben; das
Chart referenziert es über `openai.existingSecret`:

```bash
export OPENAI_API_KEY=sk-...
```

## Schnellstart

```bash
cd poc-05-argocd

./scripts/01-install-argocd.sh    # Argo CD im Cluster installieren
./scripts/02-access.sh            # Admin-Passwort zeigen + Port-Forward (UI :8080)

# In einem zweiten Terminal (Port-Forward läuft weiter):
argocd login localhost:8080 --username admin --password '<pw>' --insecure
./scripts/03-connect-repo.sh      # GitHub-Repo anbinden (bei public optional)
./scripts/04-app-secret.sh        # OpenAI-Secret im Ziel-Namespace anlegen
./scripts/05-create-app.sh        # Application anlegen (zeigt auf PoC-04-Chart)
./scripts/06-sync.sh              # Erste, manuelle Synchronisation
./scripts/08-verify.sh            # Application-Status, Pods, Service prüfen
./scripts/07-enable-autosync.sh   # Auto-Sync (prune + selfHeal) einschalten
```

Aufräumen: `./scripts/99-teardown.sh`.

## Was die Skripte tun

| Skript                     | Aktion                                                                 |
|----------------------------|------------------------------------------------------------------------|
| `01-install-argocd.sh`     | Namespace + Argo-CD-Manifest anwenden, auf `argocd-server` warten      |
| `02-access.sh`             | Initiales Admin-Passwort zeigen, Port-Forward `svc/argocd-server:443`  |
| `03-connect-repo.sh`       | `argocd repo add` (Token via `GIT_TOKEN` für private Repos)            |
| `04-app-secret.sh`         | OpenAI-Key als Kubernetes-Secret im Ziel-Namespace                     |
| `05-create-app.sh`         | Application-Vorlage mit `envsubst` rendern und `kubectl apply`         |
| `06-sync.sh`               | Erste Synchronisation (argocd-CLI, sonst kubectl-Fallback)            |
| `07-enable-autosync.sh`    | `automated` + `--auto-prune` + `--self-heal` aktivieren               |
| `08-verify.sh`             | Sync-/Health-Status, deployte Pods und Service                        |
| `99-teardown.sh`           | Application löschen; Argo CD / Namespaces nur nach Rückfrage           |

## Die Application (`manifests/application.yaml.tmpl`)

Eine Argo-CD-`Application` beschreibt **Quelle → Ziel**:

* **source:** `repoURL` + `targetRevision` + `path` (das Chart aus PoC 04),
  plus Helm-`parameters` für `image.repository`, `image.tag` und
  `openai.existingSecret`
* **destination:** der Cluster (`kubernetes.default.svc`) und der `NAMESPACE`
* **syncPolicy:** zunächst nur `CreateNamespace=true`; Auto-Sync wird bewusst
  erst durch `07-enable-autosync.sh` aktiviert, damit der Ablauf
  nachvollziehbar bleibt

Das gerenderte Manifest landet als `manifests/application.rendered.yaml`
(git-ignoriert).

## Ergebnis / Definition of Done

* `kubectl -n argocd get application <APP_NAME>` zeigt `Synced` / `Healthy`
* Die Pods laufen im Ziel-Namespace (`Running`/`Ready`), die App ist per
  Port-Forward erreichbar
* Nach `07-enable-autosync.sh` zieht Argo CD Git-Änderungen selbstständig nach

Basis für **PoC 06 – GitOps**: dort wird eine Änderung (z. B. `IMAGE_TAG` bzw.
`values.yaml`) committet und gepusht, und Argo CD deployt sie automatisch.

## Fehlersuche

* **`ComparisonError` / Repo nicht lesbar:** Chart nach Git gepusht? Stimmen
  `GIT_REPO_URL`, `GIT_TARGET_REVISION`, `CHART_PATH`?
* **`ImagePullBackOff`:** Image mit passendem Tag in der Artifact Registry?
  (PoC 04 `00-build-push.sh`) Hat der GKE-Node Pull-Rechte?
* **App startet nicht / 500:** Existiert das Secret `OPENAI_SECRET_NAME` im
  Ziel-Namespace? (`04-app-secret.sh`)

## Kostenhinweis

Läuft auf dem GKE-Cluster aus PoC 03. Nach dem Üben mit `99-teardown.sh`
aufräumen und ggf. den Cluster (PoC 03) löschen.
