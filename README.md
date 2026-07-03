# Atlas

> Persönliche Entwicklungsplattform für Softwareentwicklung, Infrastruktur und Automatisierung.

## Was ist Atlas?

Atlas ist mein persönliches HomeLab und dient als zentrale Entwicklungsplattform für zukünftige Softwareprojekte.

Anstatt für jedes neue Projekt eine separate Entwicklungsumgebung aufzusetzen, entsteht mit Atlas eine reproduzierbare Infrastruktur, auf der Anwendungen entwickelt, getestet und betrieben werden können.

Dabei steht nicht eine einzelne Anwendung im Mittelpunkt, sondern die Plattform selbst.

---

## Mission

Atlas verfolgt das Ziel, eine stabile, sichere und kontinuierlich wachsende Entwicklungsplattform aufzubauen.

Neue Technologien sollen praxisnah erlernt, Ideen schnell prototypisch umgesetzt und Software reproduzierbar bereitgestellt werden.

Langfristig soll Atlas die Grundlage für sämtliche privaten und beruflichen Entwicklungsprojekte bilden.

---

## Vision

Atlas ist kein Raspberry Pi mit einigen installierten Diensten.

Atlas ist eine persönliche Plattform, auf der Infrastruktur, Automatisierung und Softwareentwicklung gemeinsam wachsen.

Jedes Projekt soll auf einer dokumentierten, reproduzierbaren und wartbaren Infrastruktur aufbauen.

---

## Ziele

### Kurzfristig

- Linux sicher administrieren
- Docker und Docker Compose verstehen
- Containerisierte Infrastruktur aufbauen
- Reverse Proxy verstehen
- HTTPS und TLS verstehen
- Eine saubere Dokumentation etablieren

### Mittelfristig

- Eigene APIs entwickeln
- Fullstack-Projekte hosten
- Automatisierungen entwickeln
- Datenbanken professionell einsetzen
- Backup- und Restore-Strategien entwickeln
- Monitoring integrieren
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
atlas/
├── compose/
├── docs/
│   ├── references/
│   ├── services/
│   └── setup/
├── scripts/
├── .gitignore
└── README.md
```

Die eigentliche Infrastruktur wird auf dem Raspberry Pi unter

```text
/opt/atlas
```

betrieben.

Dort befinden sich zusätzlich die Laufzeitdaten:

```text
/opt/atlas
├── backups/
├── certs/
├── compose/
├── data/
├── docs/
├── logs/
├── repositories/
└── scripts/
```

---

# Aktueller Entwicklungsstand

## Version 0.3.1 – Infrastrukturplattform

### Hostsystem

- ✅ Raspberry Pi eingerichtet
- ✅ SSH mit Public-Key-Authentifizierung
- ✅ SSH-Härtung durchgeführt
- ✅ Tailscale eingerichtet
- ✅ UFW-Firewall konfiguriert

### Container-Plattform

- ✅ Docker Engine installiert
- ✅ Docker Compose eingerichtet
- ✅ Gemeinsames Docker-Netzwerk eingerichtet

### Infrastruktur

- ✅ Traefik als zentraler Reverse Proxy integriert
- ✅ PostgreSQL integriert
- ✅ n8n integriert

### Sicherheit

- ✅ HTTPS vollständig eingerichtet
- ✅ TLS-Zertifikate integriert
- ✅ HTTP → HTTPS Redirect
- ✅ HTTP Security Header
- ✅ Zentrale TLS-Terminierung

### Dokumentation

- ✅ Architektur dokumentiert
- ✅ Infrastruktur dokumentiert
- ✅ Service-Dokumentationen erstellt
- ✅ Linux-Referenz erstellt
- ✅ Docker-Referenzen erstellt

---

# Roadmap

## Version 0.4 – Reliability

Ziel ist der zuverlässige Betrieb der Plattform.

Geplante Themen:

- Backup-Konzept
- Restore-Konzept
- Monitoring
- Logging
- Update-Strategien

---

## Version 0.5 – Erste Projekte

Die Infrastruktur dient als Grundlage für erste produktive Anwendungen.

Geplant sind unter anderem:

- CrewSync
- Eigene APIs
- Weitere Fullstack-Projekte

---

## Version 1.0

Atlas bildet eine vollständig dokumentierte und reproduzierbare Entwicklungsplattform.

Neue Projekte können auf einer bestehenden Infrastruktur entwickelt, betrieben und erweitert werden.