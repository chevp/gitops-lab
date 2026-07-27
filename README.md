# GitOps Lab – Helm & Argo CD

## Übersicht

Dieses Repository dient als **Hands-on-Labor** zum Erlernen von **GitOps**, **Helm** und **Argo CD** in Kubernetes.

Die Übungen sind in einzelne **Proof of Concepts (PoCs)** unterteilt. Jeder PoC behandelt ein eigenständiges Thema und baut schrittweise auf dem Wissen der vorherigen Übungen auf.

**Ziele des Labs**

* GitOps-Prinzipien verstehen
* Helm Charts erstellen und anpassen
* Anwendungen mit Argo CD deployen
* Änderungen über Git automatisiert in Kubernetes ausrollen
* Best Practices für Struktur, Versionierung und Deployment kennenlernen

---

## Projektstruktur

```text
gitops-lab/
├── poc-01/
├── poc-02/
├── poc-03/
├── poc-04/
├── poc-05/
└── README.md
```

Jeder Ordner enthält:

```text
poc-0X/
├── README.md
├── manifests/
├── helm/
└── solutions/ (optional)
```

Das jeweilige `README.md` beschreibt die Aufgaben, Ziele und den erwarteten Endzustand.

---

# PoC 01 – Erste Kubernetes-Anwendung

## Lernziele

* Kubernetes kennenlernen
* Deployment und Service erstellen
* Anwendung im Cluster bereitstellen

### Beispielaufgaben

* Deployment erstellen
* Service anlegen
* Container-Image ändern
* Anzahl der Replikas erhöhen
* Deployment aktualisieren

---

# PoC 02 – Einführung in Helm

## Lernziele

* Helm installieren
* Erstes Helm Chart erstellen
* Werte über `values.yaml` konfigurieren

### Beispielaufgaben

* Helm Chart erzeugen
* Deployment templatisieren
* Image-Tag konfigurierbar machen
* Replica-Anzahl parametrisieren
* Chart installieren und aktualisieren

---

# PoC 03 – GitOps mit Argo CD

## Lernziele

* Argo CD installieren
* Git Repository anbinden
* Erstes GitOps Deployment durchführen

### Beispielaufgaben

* Application anlegen
* Repository verbinden
* Synchronisation ausführen
* Änderungen über Git deployen
* Auto Sync aktivieren

---

# PoC 04 – Helm und Argo CD kombinieren

## Lernziele

* Helm Charts direkt mit Argo CD deployen
* Unterschiedliche Values-Dateien verwenden

### Beispielaufgaben

* Helm Repository konfigurieren
* `values-dev.yaml` erstellen
* `values-prod.yaml` erstellen
* Deployment über Argo CD durchführen
* Unterschiede zwischen den Umgebungen testen

---

# PoC 05 – GitOps Best Practices

## Lernziele

* Repository-Struktur verbessern
* Mehrere Anwendungen verwalten
* GitOps-Workflows verstehen

### Beispielaufgaben

* App-of-Apps Pattern verwenden
* Mehrere Anwendungen deployen
* Namespaces trennen
* Git Branching ausprobieren
* Rollback durchführen

---

# Mögliche Erweiterungen

Weitere PoCs können beispielsweise folgende Themen behandeln:

* **PoC 06** – ConfigMaps & Secrets
* **PoC 07** – Ingress Controller
* **PoC 08** – Kustomize vs. Helm
* **PoC 09** – Multi-Environment Deployments
* **PoC 10** – CI/CD mit GitHub Actions oder GitLab CI
* **PoC 11** – Argo CD Image Updater
* **PoC 12** – Progressive Delivery mit Argo Rollouts

---

## Zielgruppe

Dieses Repository richtet sich an:

* DevOps Engineers
* Kubernetes-Einsteiger
* Platform Engineers
* Softwareentwickler mit Interesse an GitOps
* Teilnehmer von Workshops und Schulungen

Jeder PoC kann unabhängig bearbeitet werden. Für ein optimales Lernerlebnis empfiehlt sich jedoch die Reihenfolge der Ordner (`poc-01` bis `poc-XX`), da die Übungen aufeinander aufbauen.
