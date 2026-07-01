# PostgreSQL

## Zweck

PostgreSQL ist die zentrale relationale Datenbank der Atlas-Plattform.

Sie stellt eine persistente Datenbank für gemeinsam genutzte Infrastruktur-Dienste und zukünftige Anwendungen bereit.

Aktuelle Nutzer:

- n8n

Geplante Nutzer:

- CrewSync
- Eigene APIs
- Weitere Projekte

---

# Architektur

PostgreSQL wird ausschließlich als Docker-Container betrieben.

Die Datenbankdateien werden außerhalb des Containers gespeichert und bleiben dadurch auch nach einem Neustart oder einer Neuerstellung des Containers erhalten.

```text
/opt/atlas
├── compose/
│   └── postgres/
│       ├── compose.yaml
│       └── .env
│
└── data/
    └── postgres/
```

---

# Docker-Integration

PostgreSQL besitzt ein eigenes Docker-Compose-Projekt.

Die Konfiguration befindet sich unter

```text
/opt/atlas/compose/postgres
```

Die persistenten Daten werden unter

```text
/opt/atlas/data/postgres
```

gespeichert.

---

# Docker-Netzwerk

PostgreSQL ist mit dem gemeinsamen Docker-Netzwerk

```text
atlas-network
```

verbunden.

Dadurch können andere Dienste PostgreSQL über den Docker-Service-Namen

```text
postgres
```

erreichen.

Eine Kommunikation über feste IP-Adressen ist innerhalb der Plattform nicht erforderlich.

---

# Datenhaltung

Alle Daten werden persistent gespeichert.

Dazu gehören insbesondere:

- Datenbanken
- Tabellen
- Benutzer
- Rollen
- Indizes
- Konfigurationen

Der Container selbst bleibt zustandslos und kann jederzeit neu erstellt werden.

---

# Benutzer und Datenbanken

## Benutzer

| Benutzer | Zweck           |
| -------- | --------------- |
| atlas    | Administration  |
| n8n      | Workflow Engine |

---

## Datenbanken

| Datenbank | Besitzer |
| --------- | -------- |
| atlas     | atlas    |
| n8n       | n8n      |

---

# Zugriff

Für Entwicklungs- und Administrationszwecke wird PostgreSQL über Port

```text
5432
```

bereitgestellt.

Dadurch ist ein Zugriff beispielsweise über

- DBeaver
- IntelliJ IDEA
- psql

möglich.

Ein direkter Zugriff aus dem Internet ist nicht vorgesehen.

---

# Architekturentscheidungen

## Containerisierung

PostgreSQL wird ausschließlich als Docker-Container betrieben.

**Gründe**

- reproduzierbare Bereitstellung
- einfache Updates
- saubere Trennung vom Hostsystem

---

## Persistente Daten

Persistente Daten werden ausschließlich unter

```text
/opt/atlas/data/postgres
```

gespeichert.

---

## Konfiguration

Sensible Konfigurationswerte werden über eine `.env`-Datei verwaltet.

Dadurch kann die Compose-Datei versioniert werden, ohne Zugangsdaten zu enthalten.

---

## Status

✅ PostgreSQL erfolgreich integriert

PostgreSQL bildet die zentrale relationale Datenbank der Atlas-Plattform und dient als gemeinsame Datenbasis für Infrastruktur-Dienste sowie zukünftige Anwendungen.
