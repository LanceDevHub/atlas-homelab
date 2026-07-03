# Backup-Strategie

Dieses Dokument beschreibt die Backup-Architektur der Atlas-Plattform.

Ziel ist es, nach einem vollständigen Ausfall (z. B. Defekt der SD-Karte) den ursprünglichen Zustand der Plattform reproduzierbar wiederherstellen zu können.

Die Backup-Strategie definiert, welche Daten gesichert werden, wohin Backups übertragen werden und wie ein vollständiger Restore erfolgt.

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

Atlas trennt das Erstellen eines Backups von dessen langfristiger Speicherung.

## Backup Engine

Die Backup Engine ist für die Erstellung und Verifikation eines Backups verantwortlich.

Sie erstellt:

- PostgreSQL-Dump
- Anwendungsdaten
- Konfigurationsdateien
- Zertifikate
- Backup-Metadaten

Die Backup Engine kennt keine externen Speicherziele.

---

## Backup Destination

Backup-Ziele dienen ausschließlich der langfristigen Speicherung.

Mögliche Ziele:

- USB-Laufwerk
- Windows-PC
- Gaming-PC
- NAS
- Cloud-Speicher

Dadurch bleibt die Backup Engine unabhängig von der späteren Speicherung.

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

Anschließend werden Backups auf ein externes System übertragen.

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

Backups sollen vollständig automatisiert erstellt werden.

Langfristig umfasst dies:

- tägliche Backups
- wöchentliche Backups
- automatische Übertragung
- Backup-Rotation
- Restore-Unterstützung

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
- Langfristige Speicherung erfolgt auf externen Systemen.
- Benachrichtigungen werden ausschließlich über das Event-System verarbeitet.
- Backup-Erstellung und Backup-Speicherung sind voneinander entkoppelt.

---

# Status

## Architektur

✅ Backup-Strategie definiert

✅ Backup-Architektur festgelegt

✅ Disaster-Recovery-Konzept definiert

## Implementierung

✅ Backup Engine implementiert

⬜ Restore Engine implementieren

⬜ Backup-Übertragung implementieren

⬜ Event-System integrieren

⬜ Automatische Backup-Rotation

⬜ Vollständigen Restore testen