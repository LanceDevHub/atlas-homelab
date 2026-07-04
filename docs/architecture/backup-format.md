# Backup-Format

Dieses Dokument beschreibt den Aufbau eines Atlas-Backups.

Es definiert die Verzeichnisstruktur sowie die Bedeutung aller enthaltenen Dateien.

Die Erstellung eines Backups wird im Dokument `backup.md` beschrieben.

---

# Ziel

Das Backup-Format stellt sicher, dass jedes Atlas-Backup denselben Aufbau besitzt.

Dadurch können Backups automatisch überprüft und unabhängig von ihrer Erstellung wiederhergestellt werden.

---

# Verzeichnisstruktur

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

Alle Bestandteile besitzen einen fest definierten Zweck.

---

# backup.info

Die Datei

```text
backup.info
```

enthält Metadaten über das Backup.

Beispiel:

```text
BACKUP_VERSION=1
TIMESTAMP=2026-07-03_17-04-46
HOSTNAME=atlas
```

## BACKUP_VERSION

Beschreibt das verwendete Backup-Format.

Die Restore Engine überprüft, ob die Version unterstützt wird.

---

## TIMESTAMP

Zeitpunkt der Backup-Erstellung.

Format:

```text
YYYY-MM-DD_HH-MM-SS
```

Beispiel:

```text
2026-07-03_17-04-46
```

---

## HOSTNAME

Hostname des Systems, auf dem das Backup erstellt wurde.

Beispiel:

```text
atlas
```

---

# PostgreSQL

Alle PostgreSQL-Datenbanken werden im Verzeichnis

```text
postgres/
```

gespeichert.

Für jede Datenbank existiert genau eine Dump-Datei.

Beispiel:

```text
postgres/
├── atlas.dump
├── n8n.dump
└── paperless.dump
```

Neue Datenbanken werden automatisch ergänzt.

---

# Anwendungsdaten

Persistente Anwendungsdaten werden unter

```text
data/
```

gespeichert.

Aktuell:

```text
data/
└── n8n/
```

Zukünftige Anwendungen können weitere Unterverzeichnisse hinzufügen.

---

# Konfiguration

Alle Compose-Konfigurationen werden unter

```text
env/
```

gespeichert.

Beispiel:

```text
env/
├── postgres.env
├── n8n.env
└── traefik.env
```

Jede Datei entspricht einer `.env`-Datei eines Compose-Projekts.

---

# TLS-Zertifikate

Alle TLS-Zertifikate befinden sich unter

```text
certs/
```

Beispiel:

```text
certs/
├── atlas.key
├── atlas.crt
└── atlas.cnf
```

Die komplette Verzeichnisstruktur wird unverändert übernommen.

---

# Dateiformate

| Bestandteil | Format |
|-------------|--------|
| PostgreSQL | pg_dump Custom Format (`.dump`) |
| Metadaten | Textdatei |
| `.env` | Textdatei |
| Zertifikate | Originaldateien |
| Anwendungsdaten | Originalverzeichnisse |

---

# Erweiterbarkeit

Das Backup-Format ist bewusst modular aufgebaut.

Neue Anwendungen können zusätzliche Daten ergänzen, ohne den bestehenden Aufbau zu verändern.

Beispiele:

```text
backup/
├── postgres/
├── data/
│   ├── n8n/
│   ├── paperless/
│   └── nextcloud/
├── env/
├── certs/
└── backup.info
```

Dadurch bleibt das Backup-Format langfristig kompatibel.

---

# Versionsverwaltung

Änderungen am Backup-Format werden über

```text
BACKUP_VERSION
```

verwaltet.

Ändert sich die Struktur eines Backups, muss die Backup-Version erhöht werden.

Die Restore Engine kann dadurch ältere oder inkompatible Backups erkennen.

---

# Anforderungen

Ein gültiges Atlas-Backup muss mindestens enthalten:

- `backup.info`
- mindestens einen PostgreSQL-Dump
- `data/`
- `env/`
- `certs/`

Fehlen diese Bestandteile, gilt das Backup als unvollständig und kann nicht wiederhergestellt werden.