# Atlas Service Standard

Dieses Dokument definiert den Standard, nach dem neue Dienste in Atlas integriert werden.

Alle Infrastruktur-Dienste folgen demselben Aufbau und derselben Vorgehensweise.

---

## Ziel

Jeder Dienst soll:

- unabhängig betrieben werden können
- reproduzierbar sein
- einfach aktualisiert werden können
- klar dokumentiert sein
- sich in die bestehende Plattform integrieren

---

## Verzeichnisstruktur

Jeder Dienst besitzt eine eigene Struktur innerhalb von `/opt/atlas`.

```text
compose/
└── <service>/
    ├── compose.yaml
    └── .env

data/
└── <service>/
```

---

## Standard-Workflow

Jeder neue Dienst wird nach folgendem Ablauf integriert:

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

## Grundsätze

- Jeder Dienst besitzt genau einen Zweck.
- Persistente Daten liegen ausschließlich unter `/opt/atlas/data`.
- Compose-Dateien liegen ausschließlich unter `/opt/atlas/compose`.
- Konfigurationswerte werden über `.env` verwaltet.
- Jeder Dienst wird dokumentiert.