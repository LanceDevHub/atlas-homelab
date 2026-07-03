# Architektur

Dieses Dokument beschreibt die grundlegende Architektur der Atlas-Plattform.

Es definiert die Prinzipien, Komponenten und Strukturen, nach denen Infrastruktur und zukünftige Projekte aufgebaut werden.

Ziel ist eine reproduzierbare, modulare, sichere und langfristig wartbare Entwicklungsplattform.

---

# Architekturprinzipien

Atlas basiert auf folgenden Grundprinzipien:

- Trennung von Infrastruktur und Projekten
- Containerisierung aller Dienste
- Reproduzierbare Konfigurationen
- Klare Verantwortlichkeiten
- Zentrale Dokumentation
- Modulare Erweiterbarkeit
- Zentrale Sicherheitsfunktionen

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
        │
        ▼
/opt/atlas/data/postgres
```

Alle Infrastruktur-Dienste kommunizieren über das gemeinsame Docker-Netzwerk `atlas-network` und können dadurch unabhängig voneinander betrieben werden.

Traefik bildet den zentralen Einstiegspunkt für sämtliche Webanwendungen der Plattform und übernimmt Routing, HTTPS sowie weitere Sicherheitsfunktionen.

---

# Infrastruktur

Infrastruktur-Dienste stellen gemeinsam genutzte Funktionen für mehrere Anwendungen bereit.

Aktuelle Dienste:

- Traefik
- PostgreSQL
- n8n

Geplante Dienste:

- Redis
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
└── scripts/
```

---

# Architekturstandards

Für alle Infrastruktur-Dienste gelten folgende Standards.

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

Dadurch können sich Dienste über ihre Docker-Service-Namen erreichen.

Beispiel:

```text
postgres
n8n
traefik
redis
```

IP-Adressen werden innerhalb der Plattform nicht verwendet.

---

## Reverse Proxy

Traefik ist der zentrale Reverse Proxy der Atlas-Plattform.

Alle Webanwendungen werden ausschließlich über Traefik veröffentlicht.

Nur Traefik veröffentlicht Ports auf dem Hostsystem.

Alle übrigen Dienste kommunizieren ausschließlich über das gemeinsame Docker-Netzwerk und veröffentlichen keine eigenen HTTP- oder HTTPS-Ports.

Traefik übernimmt zusätzlich:

- TLS-Terminierung
- HTTP-zu-HTTPS-Weiterleitungen
- HTTP Security Header
- Routing anhand des Hostnamens

---

## HTTPS

HTTPS wird zentral durch Traefik bereitgestellt.

Backend-Dienste kommunizieren weiterhin unverschlüsselt innerhalb des isolierten Docker-Netzwerks.

TLS-Zertifikate werden zentral unter

```text
/opt/atlas/certs
```

verwaltet.

Dadurch müssen einzelne Dienste keine eigene HTTPS-Konfiguration besitzen.

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
- zentrale Sicherheitsfunktionen
- saubere Dokumentation
- langfristige Skalierbarkeit