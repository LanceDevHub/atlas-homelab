# Docker

## Zweck

Docker bildet die Container-Plattform von Atlas.

Alle zukünftigen Infrastruktur-Dienste und Projekte werden containerisiert betrieben. Dadurch können Anwendungen reproduzierbar bereitgestellt, aktualisiert und verwaltet werden.

---

## Architekturentscheidung

Für Atlas wurde Docker Engine mit dem offiziellen Docker Compose Plugin gewählt.

Gründe für diese Entscheidung:

- Standard in vielen professionellen Entwicklungsumgebungen
- Gute Dokumentation und große Community
- Einfache Verwaltung containerisierter Anwendungen
- Reproduzierbare Deployments mittels Docker Compose
- Plattformunabhängige Bereitstellung von Diensten

---

## Installation

Docker wurde über das offizielle Docker-Repository installiert.

Installierte Komponenten:

- Docker Engine
- Docker CLI
- Docker Compose Plugin
- Buildx Plugin
- containerd

---

## Konfiguration

Der Benutzer `lenny` wurde der Docker-Gruppe hinzugefügt, sodass Docker ohne `sudo` verwendet werden kann.

---

## Verifikation

Folgende Tests wurden erfolgreich durchgeführt:

- Docker Version geprüft
- Docker Compose Version geprüft
- Testcontainer `hello-world` erfolgreich ausgeführt

---

## Aktueller Status

✅ Docker ist erfolgreich eingerichtet und einsatzbereit.

Docker bildet die Grundlage für sämtliche zukünftigen Dienste innerhalb von Atlas.