# PostgreSQL

## Zweck

PostgreSQL dient als zentrale relationale Datenbank der Atlas-Plattform.

Sie stellt eine persistente relationale Datenbank für gemeinsam genutzte Dienste bereit.

Geplante Nutzer:

- n8n
- zukünftige APIs
- CrewSync
- weitere Projekte

---

## Architektur

PostgreSQL wird nicht direkt auf dem Raspberry Pi installiert.

Die Datenbank wird als Docker-Container betrieben.

Persistente Daten werden außerhalb des Containers gespeichert.

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

## Entscheidungen

### Containerisierung

PostgreSQL wird ausschließlich als Docker-Container betrieben.

**Begründung**

- reproduzierbare Bereitstellung
- einfache Updates
- saubere Trennung von Anwendung und Hostsystem

---

### Persistente Daten

Die Datenbankdateien werden unter

`/opt/atlas/data/postgres`

gespeichert.

Der Container selbst bleibt zustandslos und kann jederzeit neu erstellt werden.

---

### Netzwerk

Für die Entwicklungsphase wird PostgreSQL über Port `5432` auf dem Raspberry Pi bereitgestellt.

Dadurch ist ein Zugriff mit Werkzeugen wie DBeaver oder IntelliJ möglich.

Ein direkter Zugriff aus dem Internet ist nicht vorgesehen.

---

## Status

🚧 Einrichtung läuft.