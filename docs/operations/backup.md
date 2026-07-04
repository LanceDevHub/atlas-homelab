# Backup

Dieses Dokument beschreibt die technische Funktionsweise des Backup-Prozesses der Atlas-Plattform.

Das Backup wird durch das Skript

```text
scripts/backup.sh
```

erstellt.

---

# Ziel

Das Backup erstellt eine vollständige Sicherung aller nicht rekonstruierbaren Laufzeitdaten der Atlas-Plattform.

Nach erfolgreichem Abschluss kann die Plattform mithilfe von `restore.sh` vollständig wiederhergestellt werden.

Während des gesamten Backup-Prozesses werden Ereignisse über das Event-System erzeugt, sodass externe Systeme (z. B. n8n) den Ablauf verfolgen können.

---

# Voraussetzungen

Vor dem Backup müssen folgende Voraussetzungen erfüllt sein.

- PostgreSQL läuft
- Die Atlas-Verzeichnisstruktur existiert
- Die PostgreSQL-Konfiguration ist verfügbar
- Der ausführende Benutzer besitzt Lesezugriff auf alle Backup-Daten

---

# Backup-Ablauf

Das Backup besteht aus mehreren aufeinanderfolgenden Schritten.

```text
backup.started

        │
        ▼

Backup-Verzeichnis erstellen

        │
        ▼

backup.info erzeugen

        │
        ▼

PostgreSQL sichern

        │
        ▼

n8n-Daten sichern

        │
        ▼

.env-Dateien sichern

        │
        ▼

TLS-Zertifikate sichern

        │
        ▼

Backup verifizieren

        │
        ▼

Backup-Rotation

        │
        ▼

backup.completed
```

Jeder Schritt muss erfolgreich abgeschlossen werden.

Tritt während eines Schrittes ein Fehler auf, wird

- ein `backup.failed`-Event erzeugt,
- das unvollständige Backup entfernt und
- das Skript sofort beendet.

---

# Backup-Inhalt

Ein vollständiges Backup besitzt folgenden Aufbau.

```text
backup/
├── backup.info
├── postgres/
│   ├── atlas.dump
│   ├── n8n.dump
│   └── ...
├── data/
│   └── n8n/
├── env/
│   ├── postgres.env
│   ├── n8n.env
│   └── traefik.env
└── certs/
    ├── atlas.key
    ├── atlas.crt
    └── atlas.cnf
```

---

# PostgreSQL

Alle Benutzerdatenbanken werden automatisch erkannt.

Für jede Datenbank wird ein eigener PostgreSQL-Dump erstellt.

Beispielsweise:

```text
postgres/
├── atlas.dump
├── n8n.dump
└── paperless.dump
```

Dadurch unterstützt das Backup beliebig viele zukünftige Anwendungen ohne Änderungen am Skript.

---

# n8n-Daten

Zusätzlich zur Datenbank werden die lokalen n8n-Daten gesichert.

```text
/opt/atlas/data/n8n
```

Die Sicherung erfolgt inklusive

- Berechtigungen
- Zeitstempeln
- symbolischen Links

---

# Konfiguration

Alle `.env`-Dateien der Compose-Projekte werden gesichert.

Beispielsweise:

```text
compose/
├── postgres/.env
├── n8n/.env
└── traefik/.env
```

Im Backup werden sie gespeichert als

```text
env/
├── postgres.env
├── n8n.env
└── traefik.env
```

---

# TLS-Zertifikate

Die vollständige Zertifikatsstruktur wird übernommen.

```text
certs/
```

Hierzu gehören beispielsweise

- atlas.key
- atlas.crt
- atlas.cnf

---

# Backup-Metadaten

Jedes Backup enthält eine Datei

```text
backup.info
```

Sie beschreibt grundlegende Informationen über das Backup.

Beispiel:

```text
BACKUP_VERSION=1
TIMESTAMP=2026-07-03_17-04-46
HOSTNAME=atlas
```

Diese Informationen werden beim Restore zur Validierung verwendet.

---

# Verifikation

Nach dem Erstellen wird das Backup automatisch überprüft.

Dabei werden unter anderem kontrolliert:

- backup.info vorhanden
- mindestens ein PostgreSQL-Dump vorhanden
- n8n-Daten vorhanden
- alle `.env`-Dateien vorhanden
- TLS-Zertifikate vorhanden

Erst wenn alle Prüfungen erfolgreich sind, gilt das Backup als vollständig.

---

# Backup-Rotation

Nach erfolgreicher Verifikation werden alte Backups automatisch entfernt.

Es werden maximal

```text
DAILY_RETENTION
```

Backups aufbewahrt.

Ältere Sicherungen werden automatisch gelöscht.

---

# Event-System

Während des Backup-Prozesses werden Ereignisse erzeugt.

Folgende Ereignisse werden aktuell verwendet.

| Ereignis | Beschreibung |
|----------|--------------|
| `backup.started` | Backup wurde gestartet |
| `backup.completed` | Backup erfolgreich abgeschlossen |
| `backup.failed` | Backup wurde aufgrund eines Fehlers beendet |

Bei einem Fehler enthält der Payload zusätzlich den fehlgeschlagenen Verarbeitungsschritt.

Beispiel:

```json
{
    "step": "backup_postgres"
}
```

---

# Backup ausführen

Das Backup wird über das Skript gestartet.

```bash
./scripts/backup.sh
```

Nach erfolgreichem Abschluss befindet sich das Backup unter

```text
/opt/atlas/backups/daily/<timestamp>
```

---

# Fehlerbehandlung

Das Backup verwendet

```bash
set -Eeuo pipefail
```

Dadurch wird das Backup bei jedem Fehler sofort beendet.

Vor jedem kritischen Verarbeitungsschritt werden mögliche Fehler überprüft.

Bei einem Fehler

- wird ein `backup.failed`-Event erzeugt,
- das unvollständige Backup entfernt,
- der Fehler an den Benutzer ausgegeben und
- das Skript beendet.

Dadurch verbleiben niemals unvollständige Backups im Backup-Verzeichnis.

---

# Architekturentscheidungen

Atlas trifft folgende Architekturentscheidungen.

- Alle Backups werden vollständig verifiziert.
- Unvollständige Backups werden automatisch entfernt.
- Backup-Ereignisse werden über das Event-System veröffentlicht.
- PostgreSQL-Datenbanken werden automatisch erkannt.
- Alte Backups werden automatisch rotiert.
- Das Backup enthält ausschließlich nicht rekonstruierbare Daten.

---

# Status

## Architektur

✅ Backup-Prozess definiert

✅ Backup-Format definiert

✅ Backup-Verifikation definiert

## Implementierung

✅ PostgreSQL-Backup

✅ n8n-Backup

✅ Konfigurations-Backup

✅ Zertifikats-Backup

✅ Backup-Verifikation

✅ Backup-Rotation

✅ Event-System integriert

---

# Nächste Schritte

Nach erfolgreichem Erstellen eines Backups kann dieses

- lokal gespeichert,
- auf ein externes System übertragen,
- automatisiert verarbeitet oder
- mit `restore.sh` wiederhergestellt werden.