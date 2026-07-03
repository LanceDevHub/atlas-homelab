# Commands

Dieses Dokument enthält häufig verwendete Befehle für die Verwaltung der Atlas-Plattform.

Es dient als schnelles Nachschlagewerk für Betrieb, Backup, Restore und PostgreSQL.

---

# Backup

## Backup erstellen

```bash
./scripts/backup.sh
```

Erstellt ein vollständiges Atlas-Backup.

---

## Restore durchführen

```bash
./scripts/restore.sh <backup-directory>
```

Beispiel:

```bash
./scripts/restore.sh \
/opt/atlas/backups/daily/2026-07-03_17-04-46
```

---

# Docker

## Status eines Compose-Projekts

```bash
docker compose -f compose/<service>/compose.yaml ps
```

---

## Dienst starten

```bash
docker compose -f compose/<service>/compose.yaml up -d
```

---

## Dienst stoppen

```bash
docker compose -f compose/<service>/compose.yaml down
```

---

## Logs anzeigen

```bash
docker compose -f compose/<service>/compose.yaml logs
```

Live:

```bash
docker compose -f compose/<service>/compose.yaml logs -f
```

---

## Container neu starten

```bash
docker compose -f compose/<service>/compose.yaml restart
```

---

# PostgreSQL

## PostgreSQL-Umgebung laden

```bash
set -a
source /opt/atlas/compose/postgres/.env
set +a
```

---

## Mit PostgreSQL verbinden

```bash
PGPASSWORD="${POSTGRES_PASSWORD}" \
psql \
-h localhost \
-p 5432 \
-U "${POSTGRES_USER}"
```

---

## Datenbanken anzeigen

```sql
\l
```

---

## Tabellen anzeigen

```sql
\dt
```

---

## Rollen anzeigen

```sql
\du
```

---

## Verbindung verlassen

```sql
\q
```

---

# Datenbank-Backup

## Alle Datenbanken anzeigen

```sql
SELECT datname
FROM pg_database
WHERE datistemplate = false;
```

---

## Datenbank exportieren

```bash
PGPASSWORD="${POSTGRES_PASSWORD}" \
pg_dump \
-h localhost \
-U "${POSTGRES_USER}" \
-Fc \
<database> \
-f backup.dump
```

---

## Datenbank wiederherstellen

```bash
PGPASSWORD="${POSTGRES_PASSWORD}" \
pg_restore \
-h localhost \
-U "${POSTGRES_USER}" \
-d <database> \
backup.dump
```

---

# n8n

## n8n-Daten

```text
/opt/atlas/data/n8n
```

---

# Compose-Projekte

```text
/opt/atlas/compose
├── postgres
├── n8n
└── traefik
```

---

# Backups

## Daily Backups

```text
/opt/atlas/backups/daily
```

---

## Pre-Restore Backups

```text
/opt/atlas/backups/pre-restore
```

---

# Verzeichnisse

## Daten

```text
/opt/atlas/data
```

---

## Zertifikate

```text
/opt/atlas/certs
```

---

## Skripte

```text
/opt/atlas/scripts
```

---

# Git

## Repository aktualisieren

```bash
git pull
```

---

## Änderungen anzeigen

```bash
git status
```

---

## Commit erstellen

```bash
git add .
git commit -m "<message>"
```

---

## Änderungen hochladen

```bash
git push
```

---

# System

## Speicherplatz

```bash
df -h
```

---

## Verzeichnisgröße

```bash
du -sh <directory>
```

---

## Docker-Container

```bash
docker ps
```

---

## Docker-Volumes

```bash
docker volume ls
```

---

## Docker-Netzwerke

```bash
docker network ls
```

---

# SSH

## Verbindung herstellen

```bash
ssh lenny@atlas
```

---

## Dateien kopieren

```bash
scp file.txt lenny@atlas:/path/
```

---

# Häufig verwendete Verzeichnisse

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