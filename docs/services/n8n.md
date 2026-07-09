# n8n

## Zweck

n8n ist die zentrale Workflow- und Automatisierungsplattform der Atlas-Infrastruktur.

Sie verarbeitet eingehende Infrastruktur-Ereignisse und führt darauf basierend automatisierte Workflows aus.

Aktuelle Einsatzbereiche:

- Verarbeitung von Infrastruktur-Events
- Discord-Benachrichtigungen
- Workflow-Orchestrierung

Geplante Einsatzbereiche:

- Systemautomatisierung
- API-Integrationen
- Datenverarbeitung
- Eigene Workflows

---

# Architektur

n8n wird ausschließlich als Docker-Container betrieben.

Alle Konfigurationsdaten und Workflows werden außerhalb des Containers gespeichert und bleiben dadurch auch nach einem Neustart oder einer Neuerstellung des Containers erhalten.

```text
/opt/atlas
├── compose/
│   └── n8n/
│       ├── compose.yaml
│       └── .env
│
└── data/
    └── n8n/
```

---

# Docker-Integration

n8n besitzt ein eigenes Docker-Compose-Projekt.

Die Konfiguration befindet sich unter

```text
/opt/atlas/compose/n8n
```

Die persistenten Daten werden unter

```text
/opt/atlas/data/n8n
```

gespeichert.

---

# Docker-Netzwerk

n8n ist mit dem gemeinsamen Docker-Netzwerk

```text
atlas-network
```

verbunden.

Dadurch können Infrastruktur-Dienste direkt über ihre Docker-Service-Namen erreicht werden.

Aktuell nutzt n8n folgende Dienste:

| Dienst | Hostname |
| -------- | -------- |
| PostgreSQL | postgres |

---

# Datenhaltung

Persistiert werden unter anderem:

- Workflows
- Zugangsdaten (Credentials)
- Benutzerkonten
- Einstellungen
- Verschlüsselungsschlüssel
- Ausführungsdaten

Alle Daten befinden sich unter

```text
/opt/atlas/data/n8n
```

Der Container selbst bleibt zustandslos und kann jederzeit neu erstellt werden.

---

# Datenbank

n8n verwendet PostgreSQL als zentrale Datenbank.

Die Verbindung erfolgt über das gemeinsame Docker-Netzwerk.

Eigene SQLite-Dateien werden nicht verwendet.

---

# Netzwerkzugriff

n8n veröffentlicht keine Ports auf dem Raspberry Pi.

Der Zugriff erfolgt ausschließlich über den zentralen Reverse Proxy Traefik.

Aktuell ist n8n unter

```text
https://n8n.home.arpa
```

erreichbar.

Traefik übernimmt dabei:

- TLS-Terminierung
- HTTP-zu-HTTPS-Weiterleitung
- Routing anhand des Hostnamens
- Zentrale Security Header

Die Kommunikation zwischen Traefik und dem n8n-Container erfolgt weiterhin unverschlüsselt über das interne Docker-Netzwerk.

---

# Traefik-Integration

Die Veröffentlichung erfolgt vollständig über Docker Labels innerhalb der Compose-Datei.

Dabei definiert n8n selbst:

- ob der Dienst veröffentlicht werden soll
- unter welchem Hostnamen er erreichbar ist
- über welchen EntryPoint Anfragen angenommen werden
- dass HTTPS verwendet wird
- welcher interne Container-Port angesprochen werden soll

Dadurch ist keine zentrale Routing-Konfiguration erforderlich.

TLS-Zertifikate, HTTP-Weiterleitungen sowie Security Header werden zentral durch Traefik verwaltet und müssen innerhalb von n8n nicht konfiguriert werden.

---

# Event-Integration

n8n bildet die zentrale Verarbeitungsebene des Atlas Event-Systems.

Alle Infrastruktur-Komponenten erzeugen ausschließlich standardisierte Events.

Diese werden zunächst lokal gespeichert und anschließend vom Event Dispatcher per HTTP-Webhook an n8n übertragen.

```text
Backup / Restore / Transfer
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
        HTTP Webhook
            │
            ▼
            n8n
```

n8n besitzt keine Kenntnis über die Infrastruktur-Komponenten.

Es verarbeitet ausschließlich eingehende Events.

---

# Workflow-Aufbau

Der zentrale Workflow besitzt folgenden Aufbau.

```text
Webhook

↓

Event Router

├── Backup Success
├── Backup Failure
├── Restore Failure
└── Transfer Failure
```

Der Event Router entscheidet anhand des Event-Typs, welcher Teil des Workflows ausgeführt wird.

---

# Discord-Benachrichtigungen

Aktuell erzeugt n8n Benachrichtigungen für folgende Ereignisse.

## Backup

- backup.completed
- backup.failed

## Restore

- restore.failed

## Transfer

- transfer.failed

Jeder Workflow erzeugt eine einheitlich formatierte Discord-Nachricht.

Fehlerereignisse werden vor dem Versand über Formatter-Nodes aufbereitet.

Dadurch können interne Schrittbezeichnungen in lesbare Beschreibungen übersetzt werden.

---

# Architekturentscheidungen

## Containerisierung

n8n wird ausschließlich als Docker-Container betrieben.

**Gründe**

- reproduzierbare Bereitstellung
- einfache Updates
- saubere Trennung vom Hostsystem

---

## Persistente Daten

Alle Konfigurations- und Workflowdaten werden außerhalb des Containers gespeichert.

Dadurch bleiben sämtliche Daten auch nach einem Container-Update erhalten.

---

## PostgreSQL statt SQLite

Für Atlas wird PostgreSQL als Datenbank verwendet.

**Gründe**

- bessere Skalierbarkeit
- gemeinsame Datenbankplattform
- höhere Zuverlässigkeit
- einheitliche Infrastruktur

---

## Reverse Proxy

n8n wird nicht direkt veröffentlicht.

Der gesamte externe Zugriff erfolgt ausschließlich über Traefik.

Traefik übernimmt die TLS-Terminierung sowie die Bereitstellung zentraler Sicherheitsfunktionen wie HTTP-zu-HTTPS-Weiterleitungen und HTTP Security Header.

Dadurch existiert innerhalb der Atlas-Plattform nur ein zentraler Einstiegspunkt für Webanwendungen.

---

## Konfiguration

Sensible Konfigurationswerte werden über eine `.env`-Datei verwaltet.

Dazu gehören unter anderem:

- Hostname
- Datenbankzugang
- Zeitzone
- Passwörter

Dadurch kann die Compose-Datei versioniert werden, ohne vertrauliche Informationen zu enthalten.

---

## Event-Verarbeitung

n8n verarbeitet ausschließlich eingehende Infrastruktur-Ereignisse.

Die Infrastruktur kennt weder n8n noch Discord oder andere externe Systeme.

Dadurch bleiben Infrastruktur und Automatisierung vollständig voneinander entkoppelt.

---

# Status

✅ n8n erfolgreich integriert

✅ PostgreSQL als Datenbank eingebunden

✅ Traefik als Reverse Proxy eingerichtet

✅ HTTPS vollständig integriert

✅ Zugriff ausschließlich über Traefik

✅ Docker Labels für automatisches Routing eingerichtet

✅ HTTP Security Header werden zentral durch Traefik bereitgestellt

✅ Webhook für Event Dispatcher eingerichtet

✅ Event Router implementiert

✅ Discord-Benachrichtigungen integriert

✅ Formatter für Fehlerereignisse implementiert