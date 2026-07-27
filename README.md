# GitOps Lab – GitHub, Google Cloud (GKE), Helm & Argo CD

## Ziel

Dieses Repository begleitet den Aufbau einer vollständigen GitOps-Plattform auf Google Kubernetes Engine (GKE).

Die Übungen führen Schritt für Schritt durch den kompletten Workflow – von der Bereitstellung eines Kubernetes-Clusters bis zum automatisierten Deployment einer Anwendung mit Helm und Argo CD.

## Architektur

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
Helm Chart
    │
    ▼
Argo CD
    │
    ▼
Google Kubernetes Engine (GKE)
```

## Projektstruktur

```text
gitops-lab/
│
├── poc-01-github/
├── poc-02-gcloud/
├── poc-03-gke/
├── poc-04-helm/
├── poc-05-argocd/
├── poc-06-gitops/
├── poc-07-environments/
├── poc-08-advanced/
└── README.md
```

---

## PoC 01 – GitHub Repository

### Lernziele

* Repository erstellen
* Branches anlegen
* Pull Requests verwenden
* Repository strukturieren

### Aufgaben

* GitHub Repository erstellen
* README anlegen
* Feature Branch erstellen
* Pull Request öffnen
* Merge durchführen

---

## PoC 02 – Google Cloud

### Lernziele

* Google Cloud SDK installieren
* Projekt erstellen
* Authentifizierung durchführen

### Aufgaben

* `gcloud init`
* Projekt auswählen
* Billing aktivieren
* Kubernetes API aktivieren
* Container Registry oder Artifact Registry konfigurieren

---

## PoC 03 – Google Kubernetes Engine (GKE)

### Lernziele

* Kubernetes Cluster bereitstellen

### Aufgaben

* GKE Cluster erstellen
* `kubectl` konfigurieren
* Namespace erstellen
* Test-Pod deployen
* Cluster prüfen

---

## PoC 04 – Helm

### Lernziele

* Helm installieren
* Helm Chart erstellen

### Aufgaben

* Helm Chart erzeugen
* Werte parametrisieren
* Chart installieren
* Upgrade durchführen
* Rollback testen

---

## PoC 05 – Argo CD

### Lernziele

* Argo CD installieren
* GitHub anbinden

### Aufgaben

* Argo CD deployen
* GitHub Repository verbinden
* Erste Application erstellen
* Synchronisieren
* Auto Sync aktivieren

---

## PoC 06 – GitOps

### Lernziele

* Vollständigen GitOps-Workflow verstehen

### Aufgaben

* Image-Version ändern
* `values.yaml` anpassen
* Commit erstellen
* Push nach GitHub
* Deployment durch Argo CD beobachten

---

## PoC 07 – Mehrere Umgebungen

### Lernziele

* Dev-, Test- und Prod-Umgebungen verwalten

### Aufgaben

* Mehrere Values-Dateien erstellen
* Unterschiedliche Replica-Anzahlen konfigurieren
* Separate Namespaces verwenden
* Anwendungen getrennt deployen

---

## PoC 08 – Erweiterungen

### Beispiele

* App-of-Apps Pattern
* Argo CD Image Updater
* GitHub Actions
* Artifact Registry
* Monitoring
* Ingress
* TLS
* Horizontal Pod Autoscaler (HPA)
