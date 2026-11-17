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
├── poc-01-spring-ai/            # Spring-Boot-4/Spring-AI-Chat-App
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

## PoC 01 – GitHub Repository & Beispiel-Anwendung

Ursprünglich die Einstiegsübung zum GitHub-Workflow. Der Ordner `poc-01/`
enthält inzwischen zusätzlich eine lauffähige **Beispiel-Anwendung**, an der die
späteren PoCs (Container-Build, Helm, Argo CD, GitOps) deployt werden können.

### Lernziele

* Repository erstellen, Branches anlegen, Pull Requests verwenden
* Repository strukturieren
* Eine deploybare Anwendung als Grundlage für die GitOps-Pipeline bereitstellen

### Aufgaben

* GitHub Repository erstellen und strukturieren
* README anlegen
* Feature Branch erstellen, Pull Request öffnen, Merge durchführen

### Beispiel-Anwendung (`poc-01/`)

Ein provider-neutraler Chat als **Spring Boot 4 + Spring AI** Backend (OpenAI)
mit einem Plain-JS-Frontend. Dient als Deploy-Ziel der folgenden PoCs.

* **Stack:** Spring Boot 4.0, Spring AI 2.0, Java 21, Spring Data JPA + H2,
  Frontend ohne Framework (kein Build-Schritt)
* **Features:** Streaming-Chat (NDJSON), Model-Picker, „New chat", Token-Limits
  (Input 100 / Output 1000 pro Request, 2000 pro Tag)
* **Details & Start:** siehe [`poc-01-spring-ai/README.md`](poc-01-spring-ai/README.md)
  (`export OPENAI_API_KEY=… && ./mvnw spring-boot:run` → <http://localhost:8080/>)

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

Baut auf PoC 04 auf: dasselbe Helm-Chart wird per **GitOps** aus dem Repository
synchronisiert statt manuell installiert. Details & Skripte:
[`poc-05-argocd/README.md`](poc-05-argocd/README.md).

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
