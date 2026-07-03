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
Backup starten
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
Backup abgeschlossen
```

Jeder Schritt muss erfolgreich abgeschlossen werden.

Bei einem Fehler wird das Backup sofort beendet.

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

Die Sicherung erfolgt inklusive Berechtigungen und Zeitstempeln.

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

Im Backup werden sie gespeichert als:

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

Hierzu gehören beispielsweise:

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

Unvollständige Backups werden nicht als erfolgreich betrachtet.

---

# Nächste Schritte

Nach erfolgreichem Erstellen eines Backups kann dieses

- lokal gespeichert,
- auf ein externes System übertragen,
- automatisiert archiviert oder
- mit `restore.sh` wiederhergestellt werden.