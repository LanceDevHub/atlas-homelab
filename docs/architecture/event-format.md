# Event Format

Dieses Dokument definiert das Standardformat aller Ereignisse (Events) innerhalb der Atlas-Plattform.

Alle Infrastruktur-Komponenten erzeugen Ereignisse nach diesem Format.

Dadurch können Ereignisse unabhängig von ihrer Quelle einheitlich verarbeitet werden.

---

# Ziel

Das Event-Format verfolgt folgende Ziele.

- Einheitliche Ereignisstruktur
- Lose gekoppelte Komponenten
- Einfache Erweiterbarkeit
- Standardisierte Verarbeitung
- Unabhängigkeit vom Transportweg

---

# Grundprinzip

Jedes Ereignis beschreibt genau ein abgeschlossenes Ereignis innerhalb der Plattform.

Ein Event enthält ausschließlich Informationen über das Ereignis selbst.

Es beschreibt nicht, wie auf das Ereignis reagiert werden soll.

Die Verarbeitung erfolgt ausschließlich durch das Event-System.

---

# Standardstruktur

Jedes Event besitzt folgenden Aufbau.

```json
{
    "event": "...",
    "timestamp": "...",
    "source": "...",
    "status": "...",
    "payload": { }
}
```

---

# Felder

## event

Beschreibt den Ereignistyp.

Beispiele:

```text
backup.started
backup.completed
backup.failed

restore.started
restore.completed
restore.failed

backup.transfer.started
backup.transfer.completed
backup.transfer.failed

system.disk.low
container.started
```

---

## timestamp

Zeitpunkt der Ereigniserzeugung.

Verwendet wird das ISO-8601-Format.

Beispiel:

```text
2026-07-04T03:00:00Z
```

---

## source

Beschreibt die erzeugende Infrastruktur-Komponente.

Beispiele:

```text
atlas-backup
atlas-restore
atlas-backup-transfer
monitoring
traefik
postgres
n8n
```

---

## status

Beschreibt das Ergebnis des Ereignisses.

Mögliche Werte:

```text
success
warning
error
info
```

---

## payload

Enthält ereignisspezifische Informationen.

Der Inhalt hängt vom jeweiligen Ereignis ab.

Beispiel:

```json
{
    "directory": "2026-07-04_03-00-00",
    "size": "182 MB"
}
```

---

# Beispiele

## Backup erfolgreich

```json
{
    "event": "backup.completed",
    "timestamp": "2026-07-04T03:00:00Z",
    "source": "atlas-backup",
    "status": "success",
    "payload": {
        "directory": "2026-07-04_03-00-00"
    }
}
```

---

## Backup fehlgeschlagen

```json
{
    "event": "backup.failed",
    "timestamp": "2026-07-04T03:00:00Z",
    "source": "atlas-backup",
    "status": "error",
    "payload": {
        "reason": "PostgreSQL dump failed"
    }
}
```

---

## Backup übertragen

```json
{
    "event": "backup.transfer.completed",
    "timestamp": "2026-07-04T03:15:42Z",
    "source": "atlas-backup-transfer",
    "status": "success",
    "payload": {
        "directory": "2026-07-04_03-00-00"
    }
}
```

---

# Benennung

Event-Namen folgen dem Schema

```text
<domain>.<action>
```

Beispiele:

```text
backup.completed
backup.failed

restore.started
restore.completed

backup.transfer.completed

container.started

certificate.renewed
```

---

# Payload

Der Payload ist frei erweiterbar.

Gemeinsame Informationen dürfen nicht mehrfach gespeichert werden.

Folgende Informationen gehören niemals in den Payload:

- event
- timestamp
- source
- status

Diese Informationen befinden sich bereits auf oberster Ebene.

---

# Transport

Das Event-Format ist unabhängig vom verwendeten Transportweg.

Beispiele:

- JSON-Datei
- HTTP
- Webhook
- MQTT
- Redis
- RabbitMQ

Die Infrastruktur-Komponenten kennen ausschließlich das Event-Format.

---

# Versionierung

Neue Felder dürfen ergänzt werden.

Bereits definierte Felder werden nicht verändert oder entfernt.

Dadurch bleibt das Event-Format rückwärtskompatibel.

---

# Architekturentscheidungen

Atlas trifft folgende Architekturentscheidungen.

- Alle Ereignisse besitzen dieselbe Grundstruktur.
- Ereignisse werden als JSON dargestellt.
- Das Event-Format ist unabhängig vom Transportweg.
- Infrastruktur-Komponenten erzeugen ausschließlich Events.
- Die Verarbeitung erfolgt außerhalb der Infrastruktur-Komponenten.

---

# Status

## Architektur

✅ Event-Format definiert

✅ Standardfelder definiert

✅ Benennungskonvention definiert

## Implementierung

⬜ Event Library implementieren

⬜ Event Transport implementieren

⬜ Backup Engine integrieren

⬜ Restore Engine integrieren

⬜ Transfer Engine integrieren

⬜ n8n anbinden