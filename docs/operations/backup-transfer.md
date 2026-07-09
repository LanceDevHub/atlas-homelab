# Backup Transfer

Dieses Dokument beschreibt die Transfer Engine der Atlas-Plattform.

Die Transfer Engine überträgt lokal erstellte Backups auf ein externes Backup-Ziel.

Sie arbeitet unabhängig von der Backup Engine und übernimmt ausschließlich die Übertragung bereits vorhandener Backups.

Während des gesamten Transfer-Prozesses werden Ereignisse über das Event-System erzeugt, sodass externe Systeme (z. B. n8n) den Ablauf verfolgen können.

---

# Ziel

Die Transfer Engine stellt sicher, dass lokale Backups automatisch auf ein externes Backup-Ziel übertragen werden.

Dadurch werden folgende Ziele erreicht:

- Externe Datensicherung
- Trennung von Backup und Übertragung
- Automatische Synchronisation
- Wiederholte Übertragungsversuche
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
transfer.started

        │
        ▼

Backup-Ziel prüfen

        │
        ▼

Neue Backups übertragen

        │
        ▼

Bereits vorhandene Backups überspringen

        │
        ▼

Übertragung verifizieren

        │
        ▼

transfer.completed
```

Tritt während der Übertragung ein Fehler auf, wird

- ein `transfer.failed`-Event erzeugt,
- das Ereignis in der Event Queue gespeichert,
- der Transfer beendet und
- der Fehler ausgegeben.

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

# Backup-Ziel

Vor Beginn der Übertragung wird überprüft, ob das Backup-Ziel erreichbar ist.

Ist das Ziel nicht verfügbar, wird der Transfer beendet.

Beispiel:

```text
==> Checking backup destination...

Backup destination unavailable.

Transfer skipped.
```

In diesem Fall wird zusätzlich ein `transfer.failed`-Event erzeugt, damit der fehlgeschlagene Transfer zentral protokolliert und über nachgelagerte Workflows (z. B. Discord) verarbeitet werden kann.

---

# Event-System

Während des Transfer-Prozesses werden Ereignisse über die gemeinsame Event Library erzeugt.

Diese werden zunächst als JSON-Dateien in der lokalen Event Queue gespeichert.

Der Event Dispatcher überträgt sie anschließend an den zentralen n8n-Workflow, der weitere Aktionen wie Discord-Benachrichtigungen ausführt.

Folgende Ereignisse werden aktuell verwendet.

| Ereignis | Beschreibung |
|----------|--------------|
| `transfer.started` | Transfer wurde gestartet |
| `transfer.completed` | Transfer erfolgreich abgeschlossen |
| `transfer.failed` | Transfer aufgrund eines Fehlers beendet |

Bei einem Fehler enthält der Payload zusätzlich den internen Verarbeitungsschritt.

Beispiel:

```json
{
    "step": "transfer_backups"
}
```

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

# Fehlerbehandlung

Das Skript verwendet

```bash
set -Eeuo pipefail
```

Vor jedem kritischen Verarbeitungsschritt werden mögliche Fehler überprüft.

Bei einem Fehler

- wird ein `transfer.failed`-Event erzeugt,
- wird das Ereignis in der Event Queue gespeichert,
- wird der Fehler ausgegeben und
- wird das Skript beendet.

Ein unvollständiger Transfer wird niemals als erfolgreich betrachtet.

Kann das Backup-Ziel nicht erreicht werden, wird der Transfer kontrolliert beendet und als fehlgeschlagener Transfer dokumentiert.

---

# Architekturentscheidungen

Atlas trifft folgende Architekturentscheidungen.

- Backup-Erstellung und Backup-Übertragung sind getrennte Komponenten.
- Lokale Backups besitzen höchste Priorität.
- Externe Backups erfolgen unabhängig von der Backup-Erstellung.
- Bereits übertragene Backups werden nicht erneut kopiert.
- Alle Transfer-Ereignisse werden ausschließlich über das Event-System veröffentlicht.
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

✅ Event-System integriert

✅ Event Dispatcher integriert

✅ n8n integriert

⬜ Weitere Backup-Ziele integrieren