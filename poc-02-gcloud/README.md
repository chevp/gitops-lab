# PoC 02 – Google Cloud (SDK, Projekt, Auth, APIs, Artifact Registry)

Grundlage für alle folgenden PoCs: ein sauber konfiguriertes Google-Cloud-Projekt
mit aktivierten APIs und einer **Artifact Registry** als Ziel für die Container-Images
der Spring-AI-App aus [`poc-01-spring-ai`](../poc-01-spring-ai/README.md).

## Lernziele

* Google Cloud SDK (`gcloud`) installieren und initialisieren
* Ein Projekt erstellen bzw. auswählen
* Authentifizierung durchführen (User + Application Default Credentials)
* Benötigte APIs aktivieren (GKE, Artifact Registry, …)
* Artifact Registry als Docker-Repository konfigurieren

## Voraussetzungen

* Ein Google-Konto mit **aktiviertem Billing** (GKE benötigt ein Billing-Konto)
* macOS (dieses Lab): Installation via Homebrew empfohlen

## Konfiguration

Alle Skripte lesen ihre Parameter aus [`config.env`](./config.env). Diese Datei
**vor dem ersten Lauf anpassen** (Projekt-ID muss global eindeutig sein):

```bash
cp config.env config.local.env   # optional: eigene Kopie
$EDITOR config.env
```

| Variable        | Beispiel                    | Bedeutung                                    |
|-----------------|-----------------------------|----------------------------------------------|
| `PROJECT_ID`    | `gitops-lab-472811`         | global eindeutige Projekt-ID                 |
| `PROJECT_NAME`  | `GitOps Lab`                | Anzeigename                                  |
| `REGION`        | `europe-west6`              | Region (Zürich) für Registry & späteren GKE  |
| `BILLING_ACCT`  | `0X0X0X-0X0X0X-0X0X0X`      | Billing-Account-ID (`gcloud billing accounts list`) |
| `AR_REPO`       | `gitops-lab-docker`         | Name des Artifact-Registry-Docker-Repos      |

## Schnellstart

```bash
cd poc-02-gcloud

# 0. SDK installieren (macOS / Homebrew)
./scripts/00-install-sdk.sh

# 1. Login + Application Default Credentials
./scripts/01-auth.sh

# 2. Projekt erstellen/auswählen + Billing verknüpfen
./scripts/02-project.sh

# 3. Benötigte APIs aktivieren
./scripts/03-enable-apis.sh

# 4. Artifact Registry (Docker) anlegen + Docker-Auth einrichten
./scripts/04-artifact-registry.sh

# 5. Alles prüfen
./scripts/05-verify.sh
```

Jedes Skript ist **idempotent** – ein erneuter Lauf schadet nicht und überspringt
bereits erledigte Schritte.

## Was die Skripte tun

### `00-install-sdk.sh`
Installiert `google-cloud-sdk` via Homebrew (falls `gcloud` fehlt) und prüft die
Version. Alternative ohne Homebrew: <https://cloud.google.com/sdk/docs/install>.

### `01-auth.sh`
* `gcloud auth login` – interaktiver Browser-Login (User-Credentials)
* `gcloud auth application-default login` – ADC für lokale Tools/SDKs

> Diese beiden Kommandos öffnen einen Browser und sind **interaktiv**. Wenn ein
> Schritt hängt, im Terminal mit `! gcloud auth login` selbst ausführen.

### `02-project.sh`
Erstellt das Projekt (falls nicht vorhanden), setzt es als aktives Projekt
(`gcloud config set project`) und verknüpft das Billing-Konto.

### `03-enable-apis.sh`
Aktiviert die für die weiteren PoCs nötigen Dienste:

| API                              | Wofür                          |
|----------------------------------|--------------------------------|
| `container.googleapis.com`       | GKE (PoC 03)                   |
| `artifactregistry.googleapis.com`| Container-Images (dieser PoC)  |
| `compute.googleapis.com`         | Netzwerk/VMs hinter GKE        |
| `cloudresourcemanager.googleapis.com` | Projekt-/IAM-Verwaltung   |

### `04-artifact-registry.sh`
Legt ein Docker-Repository in der gewählten Region an und richtet die
Docker-Credential-Hilfe ein:

```bash
gcloud auth configure-docker ${REGION}-docker.pkg.dev
```

Push-Ziel für die App wird damit:

```text
${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO}/<image>:<tag>
```

### `05-verify.sh`
Fasst den Zustand zusammen: aktives Konto, aktives Projekt, verknüpftes Billing,
aktivierte APIs und das Registry-Repo.

## Ergebnis / Definition of Done

* `gcloud config list` zeigt das richtige Projekt und Konto
* Billing ist verknüpft (`gcloud billing projects describe`)
* Die vier APIs sind `ENABLED`
* Das Artifact-Registry-Repo existiert und Docker ist dafür authentifiziert

Damit ist die Basis für **PoC 03 – GKE** gelegt.

## Aufräumen (optional)

```bash
./scripts/99-teardown.sh   # löscht Registry-Repo; Projekt-Löschung nur nach Rückfrage
```
