# Architektur

Dieses Dokument beschreibt die grundlegende Architektur von Atlas.

Es dient als technische Referenz für den Aufbau der Plattform und definiert die Struktur, nach der neue Dienste und Projekte integriert werden.

Die Architektur soll langfristig Stabilität, Erweiterbarkeit und Wartbarkeit gewährleisten.

---

# Architekturprinzipien

Atlas basiert auf folgenden Grundprinzipien:

- Trennung von Infrastruktur und Projekten
- Containerisierung aller Anwendungen
- Reproduzierbare Konfigurationen
- Zentrale Dokumentation
- Erweiterbarkeit ohne bestehende Dienste zu beeinflussen

---

# Architekturebenen

Atlas besteht aus mehreren logisch getrennten Ebenen.

```text
                    Atlas
                      │
        ┌─────────────┴─────────────┐
        │                           │
    Infrastruktur               Projekte
        │                           │
Docker Compose             CrewSync
PostgreSQL                 AudioTagger
Redis                      APIs
Monitoring                 Experimente
Reverse Proxy
```

---

# Komponenten

Die Plattform wird in zwei Bereiche unterteilt.

## Infrastruktur

Dienste, die von mehreren Projekten genutzt werden.

Beispiele:

- Docker
- PostgreSQL
- Redis
- Reverse Proxy
- Monitoring
- Backup

Diese Komponenten bilden das Fundament der Plattform.

---

## Projekte

Eigenständige Anwendungen.

Jedes Projekt besitzt seine eigene Dokumentation sowie seine eigene Konfiguration.

Projekte können unabhängig voneinander entwickelt, gestartet oder entfernt werden.

---

# Datenstruktur

Atlas trennt Konfigurationen, Daten und Projekte voneinander.

Die endgültige Verzeichnisstruktur wird im Laufe des Projekts definiert.

Grundsätzlich wird zwischen folgenden Bereichen unterschieden:

- Infrastruktur
- Compose-Dateien
- Projektdaten
- Backups
- Skripte
- Dokumentation

---

# Erweiterbarkeit

Neue Projekte sollen ohne Änderungen an der bestehenden Infrastruktur integriert werden können.

Neue Infrastruktur-Dienste werden nur aufgenommen, wenn sie mehreren Projekten einen Mehrwert bieten.

---

# Architekturziele

Die Architektur verfolgt folgende Ziele:

- reproduzierbare Infrastruktur
- einfache Wartbarkeit
- klare Verantwortlichkeiten
- saubere Dokumentation
- langfristige Erweiterbarkeit