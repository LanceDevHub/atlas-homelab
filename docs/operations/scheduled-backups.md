# Scheduled Backups

Dieses Dokument beschreibt die automatische Ausführung der Backup-Komponenten innerhalb der Atlas-Plattform.

Geplante Backups und Backup-Übertragungen werden über systemd-Timer gestartet und führen die jeweiligen Skripte in festgelegten Zeitintervallen aus.

---

# Ziel

Die automatische Ausführung stellt sicher, dass regelmäßig aktuelle Backups erstellt und auf externe Systeme übertragen werden, ohne dass ein manueller Eingriff erforderlich ist.

Dadurch werden folgende Ziele erreicht:

- regelmäßige Datensicherung
- automatische Backup-Übertragung
- reproduzierbare Ausführungsintervalle
- automatische Ausführung nach einem Neustart
- Integration in das Linux-Service-Management

---

# Architektur

Atlas verwendet systemd zur Planung geplanter Aufgaben.

```text
                 systemd

        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
atlas-backup.timer      atlas-backup-transfer.timer
        │                             │
        ▼                             ▼
atlas-backup.service   atlas-backup-transfer.service
        │                             │
        ▼                             ▼
 scripts/backup.sh    scripts/backup-transfer.sh
```

Die Timer starten ausschließlich die jeweiligen Services.

Die eigentliche Logik befindet sich vollständig in den Skripten.

Dadurch bleiben Planung und Implementierung konsequent voneinander getrennt.

---

# Komponenten

## Backup Service

```text
systemd/atlas-backup.service
```

Startet die Backup Engine einmalig.

Der Service besitzt den Typ

```text
oneshot
```

und beendet sich nach erfolgreicher Ausführung automatisch.

---

## Backup Timer

```text
systemd/atlas-backup.timer
```

Startet die Backup Engine täglich um 03:00 Uhr.

---

## Backup Transfer Service

```text
systemd/atlas-backup-transfer.service
```

Startet die Transfer Engine einmalig.

---

## Backup Transfer Timer

```text
systemd/atlas-backup-transfer.timer
```

Startet die Transfer Engine alle 30 Minuten.

Dadurch werden Backups automatisch übertragen, sobald das externe Backup-Ziel erreichbar ist.

---

# Installation

Die systemd-Dateien verbleiben im Atlas-Repository.

```text
/opt/atlas/systemd
```

Für systemd werden symbolische Links erstellt.

```bash
sudo ln -s /opt/atlas/systemd/atlas-backup.service \
    /etc/systemd/system/atlas-backup.service

sudo ln -s /opt/atlas/systemd/atlas-backup.timer \
    /etc/systemd/system/atlas-backup.timer

sudo ln -s /opt/atlas/systemd/atlas-backup-transfer.service \
    /etc/systemd/system/atlas-backup-transfer.service

sudo ln -s /opt/atlas/systemd/atlas-backup-transfer.timer \
    /etc/systemd/system/atlas-backup-transfer.timer
```

Anschließend wird systemd neu geladen.

```bash
sudo systemctl daemon-reload
```

---

# Aktivierung

Die Timer werden dauerhaft aktiviert.

```bash
sudo systemctl enable --now atlas-backup.timer
sudo systemctl enable --now atlas-backup-transfer.timer
```

---

# Konfiguration

## Backup Timer

```ini
OnCalendar=*-*-* 03:00:00
```

Erstellt täglich um

```text
03:00 Uhr
```

ein lokales Backup.

---

## Backup Transfer Timer

```ini
OnCalendar=*:0/30
```

Prüft alle 30 Minuten, ob neue Backups auf das externe Backup-Ziel übertragen werden können.

---

# Nachholen verpasster Ausführungen

Beide Timer verwenden

```ini
Persistent=true
```

War das System zum geplanten Zeitpunkt ausgeschaltet, wird die jeweilige Aufgabe nach dem nächsten Systemstart automatisch nachgeholt.

---

# Manuelles Ausführen

## Backup

```bash
sudo systemctl start atlas-backup.service
```

---

## Backup Transfer

```bash
sudo systemctl start atlas-backup-transfer.service
```

---

# Status prüfen

## Backup Timer

```bash
systemctl status atlas-backup.timer
```

---

## Backup Transfer Timer

```bash
systemctl status atlas-backup-transfer.timer
```

---

## Alle Timer

```bash
systemctl list-timers
```

---

# Protokolle

Die Ausgabe der Skripte wird automatisch von systemd protokolliert.

## Backup

```bash
journalctl -u atlas-backup.service
```

---

## Backup Transfer

```bash
journalctl -u atlas-backup-transfer.service
```

---

# Fehlerbehandlung

Schlägt eine geplante Aufgabe fehl, beendet sich der entsprechende Service mit einem Fehlerstatus.

Der zugehörige Timer bleibt aktiv und startet die nächste geplante Ausführung automatisch.

---

# Architekturentscheidungen

Atlas trifft folgende Architekturentscheidungen.

- Planung und Implementierung sind getrennt.
- systemd-Dateien verbleiben im Git-Repository.
- systemd verwendet symbolische Links auf die Repository-Dateien.
- Backup- und Transfer-Engine werden unabhängig voneinander geplant.
- Lokale Backups besitzen höhere Priorität als die externe Übertragung.

---

# Erweiterbarkeit

Die Planung der Infrastruktur ist modular aufgebaut.

Zukünftig können weitere Services und Timer ergänzt werden, beispielsweise:

- Monitoring
- Health Checks
- Backup-Rotation
- Software-Updates
- Event-System