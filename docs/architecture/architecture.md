# Architektur

Dieses Dokument beschreibt die grundlegende Architektur der Atlas-Plattform.

Es definiert die Prinzipien, Komponenten und Strukturen, nach denen Infrastruktur und zukünftige Projekte aufgebaut werden.

Ziel ist eine reproduzierbare, modulare und langfristig wartbare Entwicklungsplattform.

---

# Architekturprinzipien

Atlas basiert auf folgenden Grundprinzipien:

- Trennung von Infrastruktur und Projekten
- Containerisierung aller Dienste
- Reproduzierbare Konfigurationen
- Klare Verantwortlichkeiten
- Zentrale Dokumentation
- Modulare Erweiterbarkeit

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

        ┌───────────────┴───────────────┐
        │                               │
   PostgreSQL                        n8n
        │
        ▼
/opt/atlas/data/postgres
```

Die Infrastruktur-Dienste kommunizieren über ein gemeinsames Docker-Netzwerk (`atlas-network`) und können dadurch unabhängig voneinander betrieben werden.

---

# Infrastruktur

Infrastruktur-Dienste stellen gemeinsam genutzte Funktionen für mehrere Anwendungen bereit.

Aktuelle Dienste:

- PostgreSQL
- n8n

Geplante Dienste:

- Redis
- Reverse Proxy
- Monitoring
- Backup

Jeder Infrastruktur-Dienst besitzt:

- ein eigenes Compose-Projekt
- ein eigenes Datenverzeichnis
- eine eigene Dokumentation
- einen klar definierten Verantwortungsbereich

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
├── compose/
│   ├── postgres/
│   └── n8n/
├── data/
│   ├── postgres/
│   └── n8n/
├── logs/
├── repositories/
└── scripts/
```

---

# Architekturstandards

Für alle Infrastruktur-Dienste gelten folgende Standards:

## Docker Compose

Jeder Dienst besitzt ein eigenes Compose-Projekt.

```text
compose/
└── <service>/
    ├── compose.yaml
    └── .env
```

---

## Persistente Daten

Container bleiben zustandslos.

Persistente Daten werden ausschließlich unter

```text
/opt/atlas/data/<service>
```

gespeichert.

---

## Netzwerke

Alle Infrastruktur-Dienste werden über das gemeinsame Docker-Netzwerk

```text
atlas-network
```

verbunden.

Dadurch können sich Dienste über ihre Servicenamen erreichen.

Beispiel:

```text
postgres
n8n
redis
```

IP-Adressen werden innerhalb der Plattform nicht verwendet.

---

## Konfiguration

Konfigurationswerte werden über `.env`-Dateien verwaltet.

Dadurch bleiben Compose-Dateien unabhängig von sensiblen Informationen und können problemlos versioniert werden.

---

# Erweiterbarkeit

Atlas ist modular aufgebaut.

Neue Infrastruktur-Dienste können unabhängig ergänzt werden, ohne bestehende Komponenten anzupassen.

Neue Projekte bauen auf der bestehenden Infrastruktur auf und folgen denselben Architekturstandards.

---

# Architekturziele

Die Architektur verfolgt folgende Ziele:

- reproduzierbare Infrastruktur
- modulare Erweiterbarkeit
- einfache Wartbarkeit
- klare Verantwortlichkeiten
- saubere Dokumentation
- langfristige Skalierbarkeit
