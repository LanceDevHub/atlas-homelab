# Atlas

> Persönliche Entwicklungsplattform für Softwareentwicklung, Infrastruktur und Automatisierung.

## Was ist Atlas?

Atlas ist mein persönliches HomeLab und dient als zentrale Entwicklungsplattform für zukünftige Softwareprojekte.

Anstatt für jedes neue Projekt eine separate Entwicklungsumgebung aufzusetzen, entsteht mit Atlas eine reproduzierbare Infrastruktur, auf der Anwendungen entwickelt, getestet und betrieben werden können.

Dabei steht nicht eine einzelne Anwendung im Mittelpunkt, sondern die Plattform selbst.

---

## Mission

Atlas verfolgt das Ziel, eine stabile und kontinuierlich wachsende Entwicklungsplattform aufzubauen.

Neue Technologien sollen praxisnah erlernt, Ideen schnell prototypisch umgesetzt und Software reproduzierbar bereitgestellt werden.

Langfristig soll Atlas die Grundlage für sämtliche privaten und beruflichen Entwicklungsprojekte bilden.

---

## Vision

Atlas ist kein Raspberry Pi mit einigen installierten Diensten.

Atlas ist eine persönliche Plattform, auf der Infrastruktur, Automatisierung und Softwareentwicklung gemeinsam wachsen.

Jedes Projekt soll auf einer sauberen, dokumentierten und reproduzierbaren Infrastruktur aufbauen.

---

## Ziele

### Kurzfristig

- Linux sicher administrieren
- Docker und Docker Compose verstehen
- Containerisierte Infrastruktur aufbauen
- n8n kennenlernen
- Eine saubere Dokumentation etablieren

### Mittelfristig

- Eigene APIs entwickeln
- Fullstack-Projekte hosten
- Automatisierungen entwickeln
- Datenbanken professionell einsetzen
- Reverse Proxy und Monitoring integrieren
- CI/CD und Deployment kennenlernen

### Langfristig

- Jedes neue Softwareprojekt beginnt auf Atlas
- Infrastruktur vollständig dokumentieren
- Wiederverwendbare Entwicklungsumgebungen schaffen
- Moderne Softwareentwicklung praxisnah lernen

---

## Grundprinzipien

Bei der Entwicklung von Atlas gelten folgende Grundsätze:

- Infrastruktur vor Anwendungen
- Dokumentation vor Komplexität
- Jede Entscheidung nachvollziehbar dokumentieren
- Reproduzierbarkeit vor Bequemlichkeit
- Kontinuierliche Verbesserung statt Perfektion

---

## Repository-Struktur

```text
atlas-homelab/
│
├── docs/
│   ├── architecture/
│   ├── reference/
│   ├── services/
│   └── setup/
│
├── compose/
├── infrastructure/
├── projects/
└── scripts/
```

> Dieses Repository dokumentiert den Aufbau von Atlas. Die eigentliche Infrastruktur wird aktuell direkt auf dem Raspberry Pi aufgebaut und betrieben.

---

## Aktueller Entwicklungsstand

### Version 0.2 – Basisplattform

#### Infrastruktur

✅ Raspberry Pi eingerichtet

✅ SSH mit Public-Key-Authentifizierung

✅ SSH-Härtung durchgeführt

✅ Tailscale eingerichtet

✅ UFW-Firewall konfiguriert

✅ Docker Engine installiert

✅ Docker Compose eingerichtet

✅ Atlas-Verzeichnisstruktur aufgebaut

✅ Gemeinsames Docker-Netzwerk eingerichtet

#### Dienste

✅ PostgreSQL als Docker-Container integriert

✅ n8n mit PostgreSQL verbunden

#### Dokumentation

✅ Architektur dokumentiert

✅ Setup dokumentiert

✅ Docker- und PostgreSQL-Referenzen erstellt

---

## Nächster Meilenstein

### Infrastruktur erweitern

- Reverse Proxy (Traefik oder Caddy)
- Redis integrieren
- Backup-Strategie entwickeln
- Monitoring aufbauen

### Dokumentation erweitern

- n8n-Dokumentation ergänzen
- Infrastruktur-Dokumentation aktualisieren
- Weitere Referenzen erstellen
