# Architektur

Dieses Dokument beschreibt die grundlegende Architektur von Atlas.

Es dient als technische Referenz für den Aufbau der Plattform und definiert die Prinzipien sowie die Struktur, nach denen Infrastruktur und Projekte organisiert werden.

Die Architektur soll langfristig Stabilität, Erweiterbarkeit und Wartbarkeit gewährleisten.

---

# Architekturprinzipien

Atlas basiert auf folgenden Grundprinzipien:

- Trennung von Infrastruktur und Projekten
- Containerisierung aller Anwendungen
- Reproduzierbare Konfigurationen
- Klare Verantwortlichkeiten
- Zentrale Dokumentation
- Erweiterbarkeit ohne Beeinflussung bestehender Dienste

---

# Systemübersicht

Atlas besteht aus mehreren logisch getrennten Ebenen.

```text
                    Atlas
                      │
        ┌─────────────┴─────────────┐
        │                           │
 Infrastruktur                 Projekte
        │                           │
 Container-Plattform        Eigene Anwendungen
 Gemeinsame Dienste         APIs
 Netzwerke                  Tools
 Speicher                   Experimente
```

Jede Ebene besitzt eine klar definierte Aufgabe und kann unabhängig weiterentwickelt werden.

---

# Komponenten

## Infrastruktur

Die Infrastruktur stellt gemeinsam genutzte Dienste bereit, die von mehreren Projekten verwendet werden können.

Beispiele:

- Container-Plattform
- Datenbanken
- Reverse Proxy
- Monitoring
- Backup
- Automatisierung

Diese Komponenten bilden das Fundament der Plattform.

---

## Projekte

Projekte sind eigenständige Anwendungen, die auf der Infrastruktur aufbauen.

Jedes Projekt besitzt:

- ein eigenes Git-Repository
- eine eigene Dokumentation
- eine eigene Konfiguration
- einen eigenen Lebenszyklus

Projekte können unabhängig voneinander entwickelt, gestartet, aktualisiert oder entfernt werden.

---

# Verzeichnisstruktur

Atlas verwendet unter `/opt/atlas` eine zentrale Verzeichnisstruktur.

```text
/opt/atlas
├── backups/       # Backups und Sicherungen
├── compose/       # Docker Compose Stacks
├── data/          # Persistente Daten der Container
├── logs/          # Eigene Logdateien
├── repositories/  # Git-Repositories
└── scripts/       # Hilfsskripte
```

## Grundsätze

- Compose-Dateien werden ausschließlich unter `compose/` abgelegt.
- Persistente Daten werden ausschließlich unter `data/` gespeichert.
- Git-Repositories liegen unter `repositories/`.
- Backups werden zentral unter `backups/` verwaltet.
- Eigene Skripte werden unter `scripts/` abgelegt.

---

# Erweiterbarkeit

Atlas ist modular aufgebaut.

Neue Projekte können unabhängig von der bestehenden Infrastruktur integriert werden.

Neue Infrastruktur-Dienste werden nur aufgenommen, wenn sie mehreren Projekten einen Mehrwert bieten oder den Betrieb der Plattform verbessern.

---

# Architekturziele

Die Architektur verfolgt folgende Ziele:

- reproduzierbare Infrastruktur
- einfache Wartbarkeit
- klare Verantwortlichkeiten
- saubere Dokumentation
- langfristige Erweiterbarkeit
- modulare Entwicklung