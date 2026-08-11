# PoC 03 – Google Kubernetes Engine (GKE)

Baut auf [PoC 02](../poc-02-gcloud/README.md) auf: das dort konfigurierte Projekt
bekommt jetzt einen **GKE-Cluster**, `kubectl` wird verbunden, ein Namespace und
ein Test-Pod angelegt und der Cluster geprüft.

## Lernziele

* Kubernetes-Cluster auf GKE bereitstellen
* `kubectl` gegen den Cluster konfigurieren
* Namespace anlegen
* Test-Pod deployen und Cluster prüfen

## Voraussetzungen

* PoC 02 abgeschlossen (Projekt, Billing, `container.googleapis.com` aktiv)
* `gcloud` authentifiziert; `kubectl` installiert
  (`gcloud components install kubectl` oder via Homebrew)

## Konfiguration

Parameter in [`config.env`](./config.env) anpassen – `PROJECT_ID` und `REGION`
müssen zu PoC 02 passen:

| Variable       | Beispiel            | Bedeutung                                  |
|----------------|---------------------|--------------------------------------------|
| `PROJECT_ID`   | `gitops-lab-000000` | Projekt aus PoC 02                         |
| `REGION`       | `europe-west6`      | Region                                     |
| `CLUSTER_NAME` | `gitops-lab`        | Name des GKE-Clusters                      |
| `REGIONAL`     | `false`             | `true` = regional (HA), `false` = zonal    |
| `ZONE`         | `europe-west6-a`    | Zone (nur bei `REGIONAL=false`)            |
| `MACHINE_TYPE` | `e2-standard-2`     | Node-Maschinentyp                          |
| `NUM_NODES`    | `2`                 | Anzahl Nodes (pro Zone)                    |
| `NAMESPACE`    | `poc-01-spring-ai`  | Namespace für die spätere App              |

## Schnellstart

```bash
cd gke

./scripts/01-create-cluster.sh    # GKE-Cluster erstellen (dauert einige Minuten)
./scripts/02-get-credentials.sh   # kubectl konfigurieren
./scripts/03-namespace.sh         # Namespace anlegen
./scripts/04-test-pod.sh          # Test-Pod deployen
./scripts/05-verify.sh            # Cluster prüfen
```

Alle Skripte sind **idempotent**. Aufräumen: `./scripts/99-teardown.sh`.

## Was die Skripte tun

| Skript                   | Aktion                                                        |
|--------------------------|--------------------------------------------------------------|
| `01-create-cluster.sh`   | `gcloud container clusters create` (zonal oder regional)     |
| `02-get-credentials.sh`  | `get-credentials` + `gke-gcloud-auth-plugin` sicherstellen   |
| `03-namespace.sh`        | `kubectl create namespace`                                   |
| `04-test-pod.sh`         | `kubectl apply` von `manifests/test-pod.yaml` + `wait Ready` |
| `05-verify.sh`           | Kontext, Cluster-Info, Nodes, Namespace, Pods                |
| `99-teardown.sh`         | Pod/Namespace löschen; Cluster nur nach Rückfrage            |

Der Test-Pod (`manifests/test-pod.yaml`) ist ein unprivilegierter nginx – nur zum
Prüfen, dass Scheduling und Netzwerk funktionieren. Die echte App aus PoC 01 wird
erst in den Helm-/Argo-CD-PoCs deployt.

## Ergebnis / Definition of Done

* `kubectl get nodes` zeigt `NUM_NODES` Nodes im Zustand `Ready`
* Der Namespace existiert
* `hello-test` läuft (`Running` / `Ready`)

Basis für **PoC 04 – Helm**.

## Kostenhinweis

Ein laufender GKE-Cluster kostet Geld (Nodes = Compute-VMs). Nach dem Üben mit
`99-teardown.sh` den Cluster löschen.
