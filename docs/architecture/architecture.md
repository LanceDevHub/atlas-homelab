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
| n8n | Workflow- und Automatisierungsplattform |
| Backup Engine | Erstellung und Verifikation von Backups |
| Restore Engine | Wiederherstellung von Backups |
| Event System | Bereitstellung von Ereignissen für Automatisierungen |
| systemd Timer | Automatische Ausführung geplanter Backups |

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
        ┌──────────────┴──────────────┐
        │                             │
   PostgreSQL                      n8n
```

Alle Infrastruktur-Dienste kommunizieren ausschließlich über das gemeinsame Docker-Netzwerk `atlas-network`.

Traefik bildet den zentralen Einstiegspunkt für sämtliche Webanwendungen der Plattform.

Zeitgesteuerte Aufgaben wie Backups werden unabhängig von den Containern über systemd ausgeführt.

---

# Infrastruktur

Die Infrastruktur stellt gemeinsam genutzte Dienste für sämtliche Projekte bereit.

Aktuelle Infrastruktur-Dienste:

- Traefik
- PostgreSQL
- n8n

Weitere Infrastruktur-Komponenten:

- Backup Engine
- Restore Engine
- Event System
- Scheduled Backups (systemd)

Geplante Infrastruktur-Dienste:

- Redis
- Monitoring

Jede Infrastruktur-Komponente besitzt:

- eine klar definierte Verantwortung
- eine eigene Dokumentation
- eine reproduzierbare Konfiguration

Containerbasierte Dienste besitzen zusätzlich:

- ein eigenes Compose-Projekt
- ein eigenes Datenverzeichnis

---

# Projekte

Projekte sind eigenständige Anwendungen, die auf der Infrastruktur aufbauen.

Jedes Projekt besitzt:

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

Alle Dienste kommunizieren ausschließlich über das gemeinsame Docker-Netzwerk.

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

## Automatisierung

Wiederkehrende Systemaufgaben werden über systemd Services und Timer ausgeführt.

Die eigentliche Logik verbleibt in den entsprechenden Skripten.

Dadurch bleiben Planung und Implementierung voneinander getrennt.

---

# Architekturdomänen

Die Gesamtarchitektur wird in mehrere eigenständige Themenbereiche unterteilt.

| Dokument | Inhalt |
|----------|--------|
| architecture.md | Gesamtarchitektur |
| backup-strategy.md | Backup- und Restore-Architektur |
| event-system.md | Ereignisse und Automatisierung |

Weitere Architekturdokumente können bei Bedarf ergänzt werden.

---

# Erweiterbarkeit

Atlas ist modular aufgebaut.

Neue Infrastruktur-Dienste können ergänzt werden, ohne bestehende Komponenten anpassen zu müssen.

Neue Projekte bauen auf der bestehenden Infrastruktur auf und folgen denselben Architekturstandards.

---

# Architekturziele

Die Architektur verfolgt folgende Ziele.

- reproduzierbare Infrastruktur
- modulare Erweiterbarkeit
- lose gekoppelte Komponenten
- klare Verantwortlichkeiten
- einfache Wartbarkeit
- zentrale Sicherheitsfunktionen
- hohe Automatisierbarkeit
- saubere Dokumentation
- langfristige Skalierbarkeit