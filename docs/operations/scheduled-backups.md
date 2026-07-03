# Scheduled Backups

Dieses Dokument beschreibt die automatische Ausführung von Backups innerhalb der Atlas-Plattform.

Geplante Backups werden über einen systemd-Timer gestartet und führen das Backup-Skript in einem festen Zeitintervall aus.

---

# Ziel

Die automatische Ausführung stellt sicher, dass regelmäßig aktuelle Backups erstellt werden, ohne dass ein manueller Eingriff erforderlich ist.

Dadurch werden folgende Ziele erreicht:

- regelmäßige Datensicherung
- reproduzierbare Backup-Intervalle
- automatische Ausführung nach einem Neustart
- Integration in das Linux-Service-Management

---

# Architektur

Atlas verwendet systemd zur Planung geplanter Backups.

```text
systemd Timer
        │
        ▼
atlas-backup.service
        │
        ▼
scripts/backup.sh
        │
        ▼
Backup erstellen
        │
        ▼
Backup verifizieren
        │
        ▼
Backup-Rotation
```

Der Timer startet ausschließlich den Backup-Service.

Die eigentliche Backup-Logik befindet sich vollständig im Skript

```text
scripts/backup.sh
```

Dadurch bleiben Planung und Backup-Implementierung voneinander getrennt.

---

# Komponenten

Die automatische Sicherung besteht aus zwei systemd-Einheiten.

## Service

```text
systemd/atlas-backup.service
```

Der Service startet das Backup-Skript genau einmal.

Er besitzt den Typ

```text
oneshot
```

und beendet sich nach erfolgreicher Ausführung automatisch.

---

## Timer

```text
systemd/atlas-backup.timer
```

Der Timer definiert den Ausführungszeitpunkt des Backup-Services.

Aktuell wird täglich ein Backup erstellt.

---

# Installation

Die systemd-Dateien werden nach

```text
/etc/systemd/system/
```

kopiert.

```bash
sudo cp systemd/atlas-backup.service /etc/systemd/system/
sudo cp systemd/atlas-backup.timer /etc/systemd/system/
```

Danach wird systemd neu geladen.

```bash
sudo systemctl daemon-reload
```

---

# Aktivierung

Der Timer wird dauerhaft aktiviert.

```bash
sudo systemctl enable atlas-backup.timer
```

Anschließend wird er gestartet.

```bash
sudo systemctl start atlas-backup.timer
```

---

# Konfiguration

Der Ausführungszeitpunkt wird im Timer definiert.

Beispiel:

```ini
OnCalendar=*-*-* 03:00:00
```

Dies startet täglich um

```text
03:00 Uhr
```

ein Backup.

---

# Nachholen verpasster Backups

Der Timer verwendet

```ini
Persistent=true
```

War das System zum geplanten Zeitpunkt ausgeschaltet, wird das Backup unmittelbar nach dem nächsten Systemstart automatisch nachgeholt.

---

# Manuelles Ausführen

Der Backup-Service kann jederzeit manuell gestartet werden.

```bash
sudo systemctl start atlas-backup.service
```

Dies entspricht einer regulären Ausführung von

```bash
./scripts/backup.sh
```

---

# Status prüfen

## Timer

```bash
systemctl status atlas-backup.timer
```

---

## Service

```bash
systemctl status atlas-backup.service
```

---

## Alle Timer

```bash
systemctl list-timers
```

---

# Protokolle

Die Ausgabe des Backup-Skripts wird automatisch von systemd protokolliert.

Logs können über

```bash
journalctl -u atlas-backup.service
```

eingesehen werden.

Die letzte Ausführung:

```bash
journalctl -u atlas-backup.service -n 50
```

Live-Ausgabe:

```bash
journalctl -fu atlas-backup.service
```

---

# Fehlerbehandlung

Schlägt das Backup fehl, beendet sich der Service mit einem Fehlerstatus.

Der Timer selbst bleibt aktiv und startet das nächste geplante Backup automatisch.

---

# Erweiterbarkeit

Die Backup-Planung ist unabhängig von der Backup-Engine.

Dadurch können zukünftig weitere Funktionen ergänzt werden, beispielsweise:

- mehrere Backup-Zeitpläne
- wöchentliche Backups
- monatliche Backups
- Offsite-Übertragung
- Benachrichtigungen über das Event-System

Die bestehende Backup-Logik muss hierfür nicht angepasst werden.