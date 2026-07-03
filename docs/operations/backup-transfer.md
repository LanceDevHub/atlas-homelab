# Backup Transfer

Dieses Dokument beschreibt die Transfer Engine der Atlas-Plattform.

Die Transfer Engine überträgt lokal erstellte Backups auf ein externes Backup-Ziel.

Sie arbeitet unabhängig von der Backup Engine und übernimmt ausschließlich die Übertragung bereits vorhandener Backups.

---

# Ziel

Die Transfer Engine stellt sicher, dass lokale Backups automatisch auf ein externes Backup-Ziel übertragen werden.

Dadurch werden folgende Ziele erreicht:

- externe Datensicherung
- Trennung von Backup und Übertragung
- automatische Synchronisation
- wiederholte Übertragungsversuche
- Unterstützung mehrerer Backup-Ziele

---

# Architektur

Die Transfer Engine wird unabhängig von der Backup Engine ausgeführt.

```text
atlas-backup.timer
        │
        ▼
atlas-backup.service
        │
        ▼
scripts/backup.sh


atlas-backup-transfer.timer
        │
        ▼
atlas-backup-transfer.service
        │
        ▼
scripts/backup-transfer.sh
```

Die Backup Engine erstellt ausschließlich lokale Backups.

Die Transfer Engine übernimmt ausschließlich deren Übertragung auf externe Systeme.

Dadurch bleiben Backup-Erstellung und Backup-Übertragung vollständig voneinander getrennt.

---

# Komponenten

Die Transfer Engine besteht aus zwei Komponenten.

## Backup-Quelle

Lokale Backups werden aus folgendem Verzeichnis übertragen.

```text
/opt/atlas/backups/daily
```

Jedes Unterverzeichnis entspricht einem vollständigen Atlas-Backup.

---

## Backup-Ziel

Aktuell erfolgt die Übertragung auf ein SMB-Netzlaufwerk.

```text
/mnt/atlas-backups
```

Das Netzlaufwerk wird dauerhaft über CIFS eingebunden.

---

# Ablauf

Der Transfer erfolgt in mehreren Schritten.

```text
Backup-Ziel prüfen

↓

Neue Backups übertragen

↓

Bereits vorhandene Backups überspringen

↓

Übertragung verifizieren

↓

Transfer abgeschlossen
```

---

# Übertragungsverhalten

Die Transfer Engine kopiert ausschließlich neue Backup-Verzeichnisse.

Bereits vorhandene Backups werden automatisch übersprungen.

Dadurch kann die Transfer Engine beliebig oft ausgeführt werden, ohne bereits übertragene Backups erneut zu kopieren.

---

# Verifikation

Nach jeder Übertragung überprüft die Transfer Engine, ob sämtliche lokalen Backup-Verzeichnisse auf dem Backup-Ziel vorhanden sind.

Fehlende Backups führen zu einem Fehler und beenden den Transfer.

---

# Fehlerbehandlung

Ist das Backup-Ziel nicht erreichbar, wird der Transfer übersprungen.

Beispiel:

```text
==> Checking backup destination...

Backup destination unavailable.

Transfer skipped.
```

Dadurch kann die Transfer Engine regelmäßig ausgeführt werden, ohne Fehler zu erzeugen, wenn das externe Backup-Ziel vorübergehend nicht verfügbar ist.

---

# Automatisierung

Die automatische Ausführung der Transfer Engine wird im Dokument

```text
scheduled-backups.md
```

beschrieben.

---

# Unterstützte Backup-Ziele

Die Transfer Engine ist unabhängig vom eigentlichen Speicherziel.

Aktuell wird folgendes Ziel unterstützt.

- Windows-PC (SMB)

Geplante Erweiterungen:

- NAS
- USB-Laufwerk
- Cloud-Speicher

Dadurch können zukünftige Backup-Ziele ergänzt werden, ohne die Transfer Engine grundlegend anzupassen.

---

# Architekturentscheidungen

Atlas trifft folgende Architekturentscheidungen.

- Backup-Erstellung und Backup-Übertragung sind getrennte Komponenten.
- Lokale Backups besitzen höchste Priorität.
- Externe Backups erfolgen unabhängig von der Backup-Erstellung.
- Bereits übertragene Backups werden nicht erneut kopiert.
- Nicht erreichbare Backup-Ziele erzeugen keinen Fehler.
- Die Transfer Engine kennt ausschließlich Quelle und Ziel der Übertragung.

---

# Status

## Architektur

✅ Transfer-Architektur definiert

✅ Backup-Quelle definiert

✅ Externes Backup-Ziel definiert

## Implementierung

✅ Transfer Engine implementiert

✅ SMB-Integration implementiert

✅ Übertragungsverifikation implementiert

⬜ Weitere Backup-Ziele integrieren