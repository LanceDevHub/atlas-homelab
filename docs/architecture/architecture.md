# Architektur

Dieses Dokument beschreibt die grundlegende Architektur der Atlas-Plattform.

Es definiert die übergeordneten Prinzipien, Komponenten und Strukturen, nach denen Atlas entwickelt und erweitert wird.

Detaillierte Entscheidungen zu einzelnen Themen wie Backup, Sicherheit oder Ereignisverarbeitung befinden sich in separaten Architekturdokumenten.

Ziel ist eine reproduzierbare, modulare, sichere und langfristig wartbare Entwicklungsplattform.

---

# Architekturprinzipien

Atlas basiert auf folgenden Grundprinzipien.

- Trennung von Infrastruktur und Projekten
- Containerisierung aller Dienste
- Lose gekoppelte Komponenten
- Klare Verantwortlichkeiten
- Reproduzierbare Konfigurationen
- Ereignisgesteuerte Kommunikation
- Zentrale Dokumentation
- Modulare Erweiterbarkeit
- Security by Default
- Automatisierung statt manueller Prozesse

---

# Verantwortlichkeiten

Atlas verfolgt konsequent das Prinzip der Single Responsibility.

Jede Komponente besitzt genau eine klar definierte Aufgabe und kennt keine internen Details anderer Komponenten.

| Komponente | Verantwortung |
|------------|---------------|
| Traefik | Routing, HTTPS und Reverse Proxy |
| PostgreSQL | Persistente Datenspeicherung |
| n8n | Verarbeitung von Infrastruktur-Events und Workflow-Automatisierung |
| Backup Engine | Erstellung und Verifikation von Backups |
| Restore Engine | Wiederherstellung von Backups |
| Transfer Engine | Übertragung lokaler Backups |
| Event Library | Erzeugen standardisierter Ereignisse |
| Event Queue | Lokale Speicherung von Ereignissen |
| Event Dispatcher | Übertragung der Ereignisse an Workflow-Systeme |
| systemd | Zeitgesteuerte Ausführung von Infrastruktur-Aufgaben |

Dadurch bleiben Komponenten unabhängig voneinander austauschbar und können getrennt weiterentwickelt werden.

---

# Systemarchitektur

Atlas besteht aus mehreren logisch getrennten Ebenen.

```text
                           Atlas

                             │

                    Raspberry Pi 5

                             │

                     Docker Engine

                             │

                     atlas-network

                          Traefik
                    (TLS Termination)

                             │
          ┌──────────────────┴──────────────────┐
          │                                     │
     PostgreSQL                              n8n


──────────────────────────────────────────────────────

 Backup Engine
 Restore Engine
 Transfer Engine
        │
        ▼
 Event Library
        │
        ▼
  Event Queue
        │
        ▼
 Event Dispatcher
        │
        ▼
      n8n Workflow
        │
        ▼
 Discord

──────────────────────────────────────────────────────

 systemd
```

Containerisierte Dienste kommunizieren ausschließlich über das gemeinsame Docker-Netzwerk `atlas-network`.

Traefik bildet den zentralen Einstiegspunkt für sämtliche Webanwendungen.

Zeitgesteuerte Aufgaben wie Backups, Restore, Backup-Übertragungen, Event-Dispatching und zukünftige Monitoring-Aufgaben werden unabhängig von Docker über systemd ausgeführt.

---

# Infrastruktur

Die Infrastruktur stellt gemeinsam genutzte Dienste und Plattformkomponenten für sämtliche Projekte bereit.

## Containerisierte Dienste

- Traefik
- PostgreSQL
- n8n

## Plattform-Komponenten

- Backup Engine
- Restore Engine
- Transfer Engine
- Event Library
- Event Queue
- Event Dispatcher
- systemd

## Geplante Komponenten

- Monitoring
- Redis

Jede Infrastruktur-Komponente besitzt

- eine klar definierte Verantwortung
- eine eigene Dokumentation
- eine reproduzierbare Konfiguration

Containerisierte Dienste besitzen zusätzlich

- ein eigenes Compose-Projekt
- ein eigenes Datenverzeichnis

---

# Projekte

Projekte sind eigenständige Anwendungen, die auf der Infrastruktur aufbauen.

Jedes Projekt besitzt

- ein eigenes Git-Repository
- eine eigene Dokumentation
- eine eigene Konfiguration
- einen eigenen Lebenszyklus

Projekte können unabhängig entwickelt, bereitgestellt und entfernt werden.

---

# Verzeichnisstruktur

Die Infrastruktur verwendet unter `/opt/atlas` eine einheitliche Verzeichnisstruktur.

```text
/opt/atlas
├── backups/
├── certs/
├── compose/
│   ├── postgres/
│   ├── traefik/
│   └── n8n/
├── data/
│   ├── postgres/
│   └── n8n/
├── docs/
├── events/
├── logs/
├── repositories/
├── scripts/
└── systemd/
```

---

# Architekturstandards

Für alle Infrastruktur-Komponenten gelten gemeinsame Standards.

## Docker Compose

Jeder containerisierte Dienst besitzt ein eigenes Compose-Projekt.

```text
compose/
└── <service>/
    ├── compose.yaml
    └── .env
```

---

## Persistente Daten

Container bleiben zustandslos.

Persistente Daten werden ausschließlich außerhalb der Container gespeichert.

```text
/opt/atlas/data/<service>
```

---

## Netzwerk

Alle containerisierten Dienste kommunizieren ausschließlich über das gemeinsame Docker-Netzwerk.

```text
atlas-network
```

Innerhalb der Plattform werden ausschließlich Docker-Service-Namen verwendet.

IP-Adressen werden nicht verwendet.

---

## Reverse Proxy

Traefik stellt den zentralen Einstiegspunkt der Plattform dar.

Nur Traefik veröffentlicht HTTP- und HTTPS-Ports auf dem Hostsystem.

Alle übrigen Dienste kommunizieren ausschließlich intern über das Docker-Netzwerk.

---

## Konfiguration

Konfigurationswerte werden über `.env`-Dateien verwaltet.

Dadurch bleiben Compose-Dateien unabhängig von vertraulichen Informationen und können versioniert werden.

---

## Ereignisse

Alle Infrastruktur-Komponenten kommunizieren über standardisierte Ereignisse.

Die Komponenten erzeugen ausschließlich Events und besitzen keine Kenntnis über nachgelagerte Systeme.

Die Verarbeitung der Ereignisse erfolgt entkoppelt über die Event Queue, den Event Dispatcher und n8n-Workflows.

Dadurch bleiben Infrastruktur, Transport und Automatisierung vollständig voneinander getrennt.

---

## Automatisierung

Wiederkehrende Infrastruktur-Aufgaben werden über systemd Services und Timer ausgeführt.

Die eigentliche Logik verbleibt in den entsprechenden Skripten.

Dadurch bleiben Planung und Implementierung voneinander getrennt.

---

# Architekturdomänen

Die Gesamtarchitektur wird in mehrere eigenständige Themenbereiche unterteilt.

| Dokument | Inhalt |
|----------|--------|
| architecture.md | Gesamtarchitektur |
| backup-strategy.md | Backup- und Restore-Architektur |
| event-format.md | Event-Struktur |
| event-system.md | Event-System |
| event-transport.md | Event-Transport |

Weitere Architekturdokumente können bei Bedarf ergänzt werden.

---

# Erweiterbarkeit

Atlas ist modular aufgebaut.

Neue Infrastruktur-Komponenten können ergänzt werden, ohne bestehende Komponenten anpassen zu müssen.

Neue Projekte bauen auf der bestehenden Infrastruktur auf und folgen denselben Architekturstandards.

---

# Architekturziele

Die Architektur verfolgt folgende Ziele.

- reproduzierbare Infrastruktur
- modulare Erweiterbarkeit
- lose gekoppelte Komponenten
- klare Verantwortlichkeiten
- ereignisgesteuerte Kommunikation
- einfache Wartbarkeit
- zentrale Sicherheitsfunktionen
- hohe Automatisierbarkeit
- saubere Dokumentation
- langfristige Skalierbarkeit