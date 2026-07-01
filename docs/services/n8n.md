# n8n

## Zweck

n8n ist die zentrale Workflow- und Automatisierungsplattform der Atlas-Infrastruktur.

Sie ermöglicht die Erstellung, Ausführung und Verwaltung automatisierter Workflows und bildet die Grundlage für zukünftige Automatisierungen innerhalb von Atlas.

Geplante Einsatzbereiche:

- Systemautomatisierung
- API-Integrationen
- Benachrichtigungen
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

| Dienst     | Hostname |
| ---------- | -------- |
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

# Zugriff

Während der Entwicklungsphase ist n8n über Port

```text
5678
```

erreichbar.

Der Zugriff erfolgt beispielsweise über:

```
http://<raspberry-pi>:5678
```

oder

```
http://atlas:5678
```

Langfristig erfolgt der Zugriff über einen Reverse Proxy mit HTTPS.

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

## Konfiguration

Sensible Konfigurationswerte werden über eine `.env`-Datei verwaltet.

Dadurch kann die Compose-Datei versioniert werden, ohne Zugangsdaten zu enthalten.

---

# Status

✅ n8n erfolgreich integriert

n8n ist vollständig in die Atlas-Infrastruktur eingebunden und nutzt PostgreSQL als zentrale Datenbank über das gemeinsame Docker-Netzwerk.
