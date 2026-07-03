# Backup-Strategie

Dieses Dokument beschreibt die Backup-Architektur der Atlas-Plattform.

Ziel ist es, nach einem vollständigen Ausfall (z. B. Defekt der SD-Karte) den ursprünglichen Zustand der Plattform reproduzierbar wiederherstellen zu können.

Die Backup-Strategie definiert, welche Daten gesichert werden, wie Backups gespeichert und übertragen werden sowie wie ein vollständiger Restore erfolgt.

Die technische Umsetzung wird in separaten Dokumentationen beschrieben.

---

# Ziele

Die Backup-Strategie verfolgt folgende Ziele.

- Schutz vor Datenverlust
- Schnelle Wiederherstellung der Plattform
- Reproduzierbare Disaster Recovery
- Trennung von Infrastruktur und Laufzeitdaten
- Automatisierte Backup-Prozesse
- Erweiterbare Backup-Ziele

---

# Grundprinzip

Atlas unterscheidet konsequent zwischen Infrastruktur und Laufzeitdaten.

## Infrastruktur

Die Infrastruktur beschreibt, wie Atlas aufgebaut ist.

Sie befindet sich vollständig im Git-Repository.

Dazu gehören unter anderem:

- Compose-Dateien
- Skripte
- Dokumentation
- Architektur
- Konfigurationsvorlagen

Die Infrastruktur kann jederzeit erneut bereitgestellt werden und wird deshalb nicht Bestandteil des Backups.

---

## Laufzeitdaten

Laufzeitdaten entstehen erst während des Betriebs der Plattform.

Sie können nicht automatisch rekonstruiert werden und müssen regelmäßig gesichert werden.

Hierzu gehören beispielsweise:

- Datenbanken
- Workflows
- Zugangsdaten
- Benutzerkonten
- TLS-Zertifikate

---

# Zu sichernde Daten

## Persistente Anwendungsdaten

```text
/opt/atlas/data
```

Enthält unter anderem:

- PostgreSQL-Datenbanken
- n8n-Workflows
- Credentials
- Benutzerkonten
- Einstellungen
- zukünftige Anwendungsdaten

Diese Daten besitzen höchste Priorität.

---

## Konfigurationsdateien

Alle `.env`-Dateien der Compose-Projekte.

```text
/opt/atlas/compose
├── postgres/.env
├── n8n/.env
└── traefik/.env
```

Sie enthalten vertrauliche Konfigurationswerte wie:

- Passwörter
- Hostnamen
- Datenbankzugänge
- API-Schlüssel

Da diese Dateien nicht versioniert werden, gehören sie zu jedem Backup.

---

## TLS-Zertifikate

```text
/opt/atlas/certs
```

Enthält beispielsweise:

```text
atlas.key
atlas.crt
atlas.cnf
```

Die Zertifikate können zwar neu erzeugt werden, ein Restore mit den ursprünglichen Zertifikaten stellt jedoch den identischen Systemzustand wieder her.

---

# Nicht zu sichernde Daten

Folgende Daten werden bewusst nicht gesichert.

## Infrastruktur

```text
compose/
docs/
scripts/
systemd/
```

Diese Daten werden vollständig über Git verwaltet.

---

## Docker-Ressourcen

Nicht Bestandteil des Backups sind:

- Docker Images
- Docker Container
- Docker-Netzwerke

Diese Ressourcen werden bei Bedarf neu erstellt.

---

## Temporäre Daten

Nicht gesichert werden:

```text
logs/
backups/
```

Diese Daten besitzen keinen langfristigen Wert.

---

# Backup-Architektur

Atlas trennt die Erstellung eines Backups von dessen langfristiger Speicherung.

## Backup Engine

Die Backup Engine ist für die Erstellung und Verifikation eines Backups verantwortlich.

Sie erstellt:

- einen Dump jeder PostgreSQL-Datenbank
- Anwendungsdaten
- Konfigurationsdateien
- TLS-Zertifikate
- Backup-Metadaten

Die Backup Engine kennt keine externen Speicherziele.

Die Übertragung auf externe Backup-Ziele erfolgt ausschließlich durch die Transfer Engine.

---

## Transfer Engine

Die Transfer Engine übernimmt ausschließlich die Übertragung bereits vorhandener Backups auf externe Backup-Ziele.

Mögliche Ziele:

- USB-Laufwerk
- Windows-PC
- Gaming-PC
- NAS
- Cloud-Speicher

Dadurch bleiben Backup-Erstellung und Backup-Übertragung vollständig voneinander getrennt.

---

# Backup-Ebenen

Atlas unterscheidet zwei Backup-Ebenen.

## Lokales Backup

Backups werden zunächst lokal auf dem Raspberry Pi erstellt.

```text
/opt/atlas/backups
```

Diese dienen der kurzfristigen Wiederherstellung und als Ausgangspunkt für die Übertragung.

---

## Externes Backup

Anschließend werden Backups durch die Transfer Engine auf ein externes System übertragen.

Beispiele:

- Laptop
- Gaming-PC
- NAS
- Cloud

Erst das externe Backup schützt vor einem vollständigen Ausfall der SD-Karte.

---

# Disaster Recovery

Ein vollständiger Restore erfolgt grundsätzlich nach folgendem Ablauf.

```text
Neue SD-Karte

↓

Raspberry Pi OS installieren

↓

SSH einrichten

↓

Docker installieren

↓

Atlas-Repository klonen

↓

Backup wiederherstellen

↓

Container starten

↓

System verifizieren

↓

Atlas ist wieder betriebsbereit
```

Die Infrastruktur wird vollständig aus dem Git-Repository rekonstruiert.

Das Backup ergänzt ausschließlich die Laufzeitdaten.

---

# Automatisierung

Die Backup-Komponenten werden automatisch über systemd-Timer ausgeführt.

Aktuell umfasst die Automatisierung:

- tägliche Backups
- Backup-Verifikation
- Backup-Rotation
- automatische Backup-Übertragung
- Restore-Unterstützung

Geplante Erweiterungen:

- Benachrichtigungen
- wöchentliche Backups
- monatliche Backups

---

# Benachrichtigungen

Die Backup Engine versendet keine Benachrichtigungen.

Stattdessen erzeugt sie Ereignisse, die von der zentralen Workflow-Plattform verarbeitet werden.

Dadurch bleibt die Backup-Infrastruktur unabhängig von externen Diensten.

Die konkrete Event-Architektur wird im Dokument

```text
event-system.md
```

beschrieben.

---

# Architekturentscheidungen

Atlas trifft folgende grundlegende Architekturentscheidungen.

- Infrastruktur und Laufzeitdaten werden strikt getrennt.
- Das Git-Repository ist die Quelle der Infrastruktur.
- Backups sind die Quelle der Laufzeitdaten.
- Backups werden zunächst lokal erstellt.
- Lokale Backups besitzen höhere Priorität als die externe Übertragung.
- Backup-Erstellung und Backup-Übertragung sind voneinander getrennt.
- Langfristige Speicherung erfolgt auf externen Systemen.
- Wiederkehrende Backups werden automatisch über systemd ausgeführt.
- Benachrichtigungen werden ausschließlich über das Event-System verarbeitet.

---

# Status

## Architektur

✅ Backup-Strategie definiert

✅ Backup-Architektur festgelegt

✅ Disaster-Recovery-Konzept definiert

## Implementierung

✅ Backup Engine implementiert

✅ Restore Engine implementiert

✅ Transfer Engine implementiert

✅ Backup-Rotation implementiert

✅ Geplante Backups über systemd

✅ Automatische Backup-Übertragung

✅ Vollständigen Restore getestet

⬜ Event-System integrieren

⬜ Benachrichtigungen implementieren

⬜ Weitere Backup-Ziele integrieren

⬜ Wöchentliche und monatliche Backups