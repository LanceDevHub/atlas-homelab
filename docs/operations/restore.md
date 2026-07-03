# Restore

Dieses Dokument beschreibt die technische Funktionsweise des Restore-Prozesses der Atlas-Plattform.

Der Restore wird durch das Skript

```text
scripts/restore.sh
```

durchgeführt.

---

# Ziel

Der Restore stellt eine zuvor erstellte Atlas-Sicherung vollständig wieder her.

Dabei werden alle gesicherten Laufzeitdaten auf den Zustand des gewählten Backups zurückgesetzt.

---

# Voraussetzungen

Vor dem Restore müssen folgende Voraussetzungen erfüllt sein.

- Ein vollständiges Atlas-Backup liegt vor.
- Die Atlas-Infrastruktur wurde bereits installiert.
- Docker und Docker Compose sind verfügbar.
- PostgreSQL kann gestartet werden.
- Der ausführende Benutzer besitzt Schreibrechte auf die Atlas-Verzeichnisse.

---

# Restore-Ablauf

Der Restore besteht aus mehreren aufeinanderfolgenden Schritten.

```text
Restore starten
        │
        ▼
Backup verifizieren
        │
        ▼
Backup-Informationen anzeigen
        │
        ▼
Benutzerbestätigung
        │
        ▼
Atlas-Dienste stoppen
        │
        ▼
Pre-Restore-Backup erstellen
        │
        ▼
PostgreSQL wiederherstellen
        │
        ▼
n8n-Daten wiederherstellen
        │
        ▼
.env-Dateien wiederherstellen
        │
        ▼
TLS-Zertifikate wiederherstellen
        │
        ▼
Atlas-Dienste starten
        │
        ▼
Restore verifizieren
        │
        ▼
Restore abgeschlossen
```

Jeder Schritt muss erfolgreich abgeschlossen werden.

Bei einem Fehler wird der Restore sofort beendet.

---

# Backup-Verifikation

Vor Beginn des Restores wird das gewählte Backup überprüft.

Folgende Bestandteile werden kontrolliert:

- Backup-Verzeichnis vorhanden
- backup.info vorhanden
- unterstützte Backup-Version
- PostgreSQL-Dumps vorhanden
- n8n-Daten vorhanden
- alle `.env`-Dateien vorhanden
- TLS-Zertifikate vorhanden

Nur ein vollständiges Backup kann wiederhergestellt werden.

---

# Benutzerbestätigung

Vor dem Überschreiben der aktuellen Installation muss der Benutzer den Restore ausdrücklich bestätigen.

```text
Type YES to continue:
```

Erst danach beginnt der eigentliche Restore.

---

# Dienste stoppen

Vor der Wiederherstellung werden alle Atlas-Dienste kontrolliert heruntergefahren.

Aktuell umfasst dies:

- PostgreSQL
- n8n
- Traefik

Dadurch wird sichergestellt, dass während des Restores keine Dateien verändert werden.

---

# Pre-Restore-Backup

Vor jeder Wiederherstellung wird automatisch eine Sicherung des aktuellen Systemzustands erstellt.

Diese wird gespeichert unter

```text
/opt/atlas/backups/pre-restore/
```

Gesichert werden:

- n8n-Daten
- `.env`-Dateien
- TLS-Zertifikate

Das Pre-Restore-Backup ermöglicht eine manuelle Rückkehr zum vorherigen Zustand.

---

# PostgreSQL

Während des Restores wird PostgreSQL zunächst gestartet.

Anschließend erfolgt für jede gesicherte Datenbank:

1. laufende Verbindungen beenden
2. Datenbank löschen
3. Datenbank neu anlegen
4. PostgreSQL-Dump wiederherstellen

Mehrere Datenbanken werden automatisch erkannt und nacheinander wiederhergestellt.

Beispielsweise:

```text
postgres/
├── atlas.dump
├── n8n.dump
└── paperless.dump
```

Dadurch unterstützt der Restore beliebig viele Anwendungen.

---

# n8n-Daten

Nach dem Datenbank-Restore werden die lokalen n8n-Daten wiederhergestellt.

```text
/opt/atlas/data/n8n
```

Vorhandene Daten werden zuvor entfernt.

---

# Konfiguration

Alle gesicherten `.env`-Dateien werden an ihre ursprünglichen Speicherorte zurückkopiert.

Beispielsweise:

```text
env/
├── postgres.env
├── n8n.env
└── traefik.env
```

werden wiederhergestellt nach

```text
compose/
├── postgres/.env
├── n8n/.env
└── traefik/.env
```

---

# TLS-Zertifikate

Die vorhandenen Zertifikate werden entfernt.

Anschließend wird der gesamte Zertifikatsspeicher aus dem Backup wiederhergestellt.

```text
certs/
```

---

# Dienste starten

Nach Abschluss aller Restore-Schritte werden die Atlas-Dienste wieder gestartet.

Aktuell:

- PostgreSQL
- n8n
- Traefik

---

# Restore-Verifikation

Zum Abschluss wird überprüft, ob alle Dienste erfolgreich gestartet wurden.

Kontrolliert werden:

- PostgreSQL läuft
- n8n läuft
- Traefik läuft

Nur wenn alle Dienste erfolgreich laufen, gilt der Restore als abgeschlossen.

---

# Restore ausführen

Der Restore wird über das Skript gestartet.

```bash
./scripts/restore.sh /opt/atlas/backups/daily/<timestamp>
```

Beispiel:

```bash
./scripts/restore.sh \
/opt/atlas/backups/daily/2026-07-03_17-04-46
```

---

# Fehlerbehandlung

Das Restore-Skript verwendet

```bash
set -Eeuo pipefail
```

Dadurch wird der Restore bei jedem Fehler sofort beendet.

Ein unvollständiger Restore wird niemals als erfolgreich betrachtet.

---

# Hinweise

Ein Restore überschreibt den aktuellen Zustand der Atlas-Plattform.

Vor jeder Wiederherstellung wird deshalb automatisch ein Pre-Restore-Backup erstellt.

Dadurch kann der Zustand unmittelbar vor dem Restore bei Bedarf erneut eingespielt werden.