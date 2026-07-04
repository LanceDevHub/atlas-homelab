# Event-System

Dieses Dokument beschreibt die Event-Architektur der Atlas-Plattform.

Atlas verwendet ein ereignisgesteuertes (Event-Driven) Architekturmodell, um Infrastruktur-Komponenten von Automatisierungen und Benachrichtigungen zu entkoppeln.

Dadurch bleiben einzelne Komponenten unabhängig voneinander und können ohne gegenseitige Abhängigkeiten erweitert oder ausgetauscht werden.

---

# Ziel

Das Event-System verfolgt folgende Ziele.

- Lose gekoppelte Komponenten
- Klare Verantwortlichkeiten
- Einheitliche Kommunikation
- Erweiterbare Automatisierungen
- Zentrale Workflow-Steuerung
- Unabhängigkeit von Benachrichtigungsdiensten

---

# Grundprinzip

Infrastruktur-Komponenten kommunizieren niemals direkt mit externen Diensten.

Stattdessen erzeugen sie Ereignisse (Events), welche anschließend von der zentralen Workflow-Plattform verarbeitet werden.

Dadurch besitzt jede Komponente genau eine Aufgabe.

Alle Infrastruktur-Komponenten erzeugen ihre Ereignisse über die gemeinsame Event-Bibliothek (`event_emit()`), wodurch alle Events automatisch dasselbe Format besitzen.

Beispiel:

```text
Backup Engine

↓

backup.completed

↓

Event Library

↓

JSON Event

↓

n8n

↓

Discord
```

Die Backup Engine kennt weder Discord noch andere Benachrichtigungssysteme.

---

# Architektur

Das Event-System besteht aus vier Ebenen.

```text
                    Infrastruktur

      ┌────────┬─────────┬──────────┬────────────┐
      │        │         │          │            │
 Backup  Restore  Transfer  Monitoring  Deployments
      │        │         │          │
      └────────┴─────────┴──────────┘
                 │
                 ▼
            Event Library
          (event_emit())
                 │
                 ▼
            JSON Event Files
                 │
                 ▼
                n8n
      ┌──────────┼──────────┐
      │          │          │
      ▼          ▼          ▼
   Discord     E-Mail   Weitere Workflows
```

Alle Infrastruktur-Komponenten kommunizieren ausschließlich über die Event Library.

Die eigentliche Automatisierung erfolgt vollständig innerhalb von n8n.

---

# Komponenten

## Infrastruktur

Die Infrastruktur erzeugt ausschließlich Ereignisse.

Beispiele:

- Backup gestartet
- Backup abgeschlossen
- Backup fehlgeschlagen
- Restore gestartet
- Restore abgeschlossen
- Restore fehlgeschlagen
- Backup übertragen
- Backup-Übertragung fehlgeschlagen

Die Infrastruktur entscheidet nicht, wie auf ein Ereignis reagiert wird.

---

## Event Library

Die Event Library stellt eine gemeinsame API zur Erzeugung von Ereignissen bereit.

Aktuell besteht sie aus folgenden Funktionen:

- `event_emit()`
- `event_payload()`

Sie übernimmt unter anderem:

- Erzeugung des Zeitstempels
- Dateinamen
- JSON-Formatierung
- Schreiben der Event-Datei

Dadurch müssen Infrastruktur-Komponenten keine JSON-Dateien selbst erzeugen.

---

## Event-System

Das Event-System dient als standardisierte Schnittstelle zwischen Infrastruktur und Workflow-Plattform.

Es beschreibt:

- Ereignistyp
- Zeitpunkt
- Quelle
- Status
- Payload

Das Event-System besitzt keine Logik zur Verarbeitung der Ereignisse.

---

## n8n

n8n bildet die zentrale Workflow-Engine der Plattform.

Es verarbeitet eingehende Ereignisse und entscheidet, welche Aktionen ausgeführt werden.

Beispiele:

- Discord-Benachrichtigung
- E-Mail versenden
- Backup übertragen
- Erneuter Übertragungsversuch
- Weitere Automatisierungen

---

# Ereignisabläufe

## Erfolgreiches Backup

```text
backup.sh

↓

event_emit()

↓

backup.completed

↓

JSON Event

↓

n8n

↓

Discord
```

---

## Backup fehlgeschlagen

```text
backup.sh

↓

event_emit()

↓

backup.failed

↓

JSON Event

↓

n8n

↓

Discord
```

---

## Erfolgreicher Restore

```text
restore.sh

↓

event_emit()

↓

restore.completed

↓

JSON Event

↓

n8n
```

---

## Erfolgreiche Backup-Übertragung

```text
backup-transfer.sh

↓

event_emit()

↓

transfer.completed

↓

JSON Event

↓

n8n
```

---

## Monitoring

```text
Monitoring

↓

system.disk.low

↓

JSON Event

↓

n8n

↓

Discord
```

---

# Event-Typen

Aktuell werden unter anderem folgende Ereignisse verwendet.

## Backup

- backup.started
- backup.completed
- backup.failed

---

## Restore

- restore.started
- restore.completed
- restore.failed

---

## Transfer

- transfer.started
- transfer.completed
- transfer.failed

---

## Monitoring

Geplant:

- system.cpu.high
- system.memory.high
- system.disk.low
- service.unreachable

---

## Infrastruktur

Geplant:

- container.started
- container.stopped
- deployment.completed
- certificate.renewed

---

# Benachrichtigungen

Benachrichtigungen werden niemals direkt von Infrastruktur-Komponenten versendet.

Alle Benachrichtigungen erfolgen ausschließlich über n8n.

Dadurch können Benachrichtigungskanäle jederzeit ergänzt oder ersetzt werden.

Beispiele:

- Discord
- E-Mail
- Microsoft Teams
- Slack
- Telegram
- Weitere Messenger

---

# Vorteile

Die Event-Architektur bietet mehrere Vorteile.

- Lose gekoppelte Komponenten
- Einheitliches Event-Format
- Gemeinsame Event Library
- Hohe Erweiterbarkeit
- Austauschbare Benachrichtigungssysteme
- Zentrale Workflow-Verwaltung
- Keine direkten Abhängigkeiten zwischen Infrastruktur-Komponenten

---

# Architekturentscheidungen

Atlas trifft folgende Architekturentscheidungen.

- Infrastruktur erzeugt ausschließlich Ereignisse.
- Infrastruktur kennt keine externen Dienste.
- Alle Komponenten verwenden die gemeinsame Event Library.
- Ereignisse werden als JSON-Dateien erzeugt.
- n8n verarbeitet sämtliche Ereignisse.
- Benachrichtigungen erfolgen ausschließlich über n8n.
- Neue Workflows können ergänzt werden, ohne bestehende Infrastruktur anzupassen.

---

# Status

## Architektur

✅ Event-System definiert

✅ Event Library definiert

✅ Event-Format definiert

## Implementierung

✅ Event Library implementiert

✅ Backup integriert

✅ Restore integriert

✅ Transfer integriert

⬜ n8n anbinden

⬜ Monitoring integrieren

⬜ Deployment Events integrieren

---

# Zukünftige Erweiterungen

Das Event-System bildet die Grundlage für zukünftige Automatisierungen.

Geplante Erweiterungen:

- Monitoring
- Software-Updates
- Deployment-Pipelines
- Health Checks
- Sicherheitsbenachrichtigungen
- Projektautomatisierungen