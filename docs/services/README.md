# Atlas Service Standard

Dieses Dokument definiert den Standard, nach dem neue Dienste in Atlas integriert werden.

Alle containerisierten Infrastruktur-Dienste folgen demselben Aufbau und derselben Vorgehensweise.

---

# Ziel

Jeder Dienst soll:

- unabhängig betrieben werden können
- reproduzierbar sein
- einfach aktualisiert werden können
- klar dokumentiert sein
- sich nahtlos in die bestehende Plattform integrieren

---

# Verzeichnisstruktur

Jeder Dienst besitzt eine eigene Struktur innerhalb von `/opt/atlas`.

```text
compose/
└── <service>/
    ├── compose.yaml
    └── .env

data/
└── <service>/
```

Compose-Dateien enthalten ausschließlich die Definition des Dienstes.

Persistente Daten werden außerhalb der Container gespeichert.

---

# Standard-Workflow

Jeder neue Dienst wird nach folgendem Ablauf integriert.

1. Dienst auswählen
2. Service-Verzeichnis erstellen
3. `compose.yaml` erstellen
4. `.env` anlegen
5. Datenverzeichnis erstellen
6. Container starten
7. Funktion testen
8. Dokumentation ergänzen
9. Änderungen committen

---

# Grundsätze

- Jeder Dienst besitzt genau eine klar definierte Verantwortung.
- Persistente Daten liegen ausschließlich unter `/opt/atlas/data`.
- Compose-Dateien liegen ausschließlich unter `/opt/atlas/compose`.
- Konfigurationswerte werden über `.env` verwaltet.
- Jeder Dienst wird vollständig dokumentiert.
- Jeder Dienst besitzt ein eigenes Compose-Projekt.
- Dienste kommunizieren ausschließlich über `atlas-network`.
- Vertrauliche Konfigurationswerte werden nicht versioniert.

---

# Geltungsbereich

Dieser Standard gilt ausschließlich für containerisierte Infrastruktur-Dienste.

Beispiele:

- Traefik
- PostgreSQL
- n8n

Nicht Bestandteil dieses Standards sind Infrastruktur-Komponenten wie:

- Backup Engine
- Restore Engine
- Transfer Engine
- systemd-Services und -Timer
- Event-System

Diese Komponenten besitzen eigene Architektur- und Betriebsdokumentationen.