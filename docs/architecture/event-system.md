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

Beispiel:

```text
Backup Engine

↓

Backup erfolgreich

↓

Event

↓

n8n

↓

Discord
```

Die Backup Engine kennt weder Discord noch andere Benachrichtigungssysteme.

---

# Architektur

Das Event-System besteht aus drei Ebenen.

```text
                    Infrastruktur

      ┌────────┬─────────┬──────────┬────────────┐
      │        │         │          │            │
 Backup  Restore  Transfer  Monitoring  Deployments
      │        │         │          │            │
      └────────┴─────────┴──────────┴────────────┘
                       │
                       ▼
                  Event-System
                       │
                       ▼
                      n8n
         ┌─────────────┼─────────────┐
         │             │             │
         ▼             ▼             ▼
      Discord       E-Mail     Weitere Workflows
```

Alle Infrastruktur-Komponenten kommunizieren ausschließlich mit dem Event-System.

Die eigentliche Automatisierung erfolgt vollständig innerhalb von n8n.

---

# Komponenten

## Infrastruktur

Die Infrastruktur erzeugt ausschließlich Ereignisse.

Beispiele:

- Backup abgeschlossen
- Restore abgeschlossen
- Backup übertragen
- Backup fehlgeschlagen
- Monitoring-Warnung
- Deployment abgeschlossen
- Zertifikat erneuert

Die Infrastruktur entscheidet nicht, wie auf ein Ereignis reagiert wird.

---

## Event-System

Das Event-System dient als standardisierte Schnittstelle zwischen Infrastruktur und Workflow-Plattform.

Es beschreibt:

- Art des Ereignisses
- Zeitpunkt
- Quelle
- Status
- zusätzliche Informationen

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

Backup erfolgreich

↓

Event

↓

n8n

↓

Discord
```

---

## Erfolgreiche Backup-Übertragung

```text
backup-transfer.sh

↓

Backup übertragen

↓

Event

↓

n8n

↓

Discord
```

---

## Backup-Ziel nicht erreichbar

```text
backup-transfer.sh

↓

Backup-Ziel nicht erreichbar

↓

Event

↓

n8n

↓

Discord

↓

Erneuter Übertragungsversuch
```

---

## Backup fehlgeschlagen

```text
backup.sh

↓

PostgreSQL-Backup fehlgeschlagen

↓

Event

↓

n8n

↓

Discord
```

---

## Monitoring

```text
Monitoring

↓

CPU-Auslastung kritisch

↓

Event

↓

n8n

↓

Discord
```

---

# Event-Typen

Langfristig sollen unter anderem folgende Ereignisse unterstützt werden.

## Backup

- Backup erfolgreich
- Backup fehlgeschlagen
- Backup übertragen
- Backup-Ziel nicht erreichbar

---

## Restore

- Restore gestartet
- Restore abgeschlossen
- Restore fehlgeschlagen

---

## Monitoring

- Hohe CPU-Auslastung
- Hohe RAM-Auslastung
- Wenig Speicherplatz
- Dienst nicht erreichbar

---

## Infrastruktur

- Container gestartet
- Container gestoppt
- Deployment abgeschlossen
- Zertifikat erneuert

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
- Klare Verantwortlichkeiten
- Hohe Erweiterbarkeit
- Austauschbare Benachrichtigungssysteme
- Zentrale Workflow-Verwaltung
- Keine direkten Abhängigkeiten zwischen Infrastruktur-Komponenten

---

# Architekturentscheidungen

Atlas trifft folgende Architekturentscheidungen.

- Infrastruktur erzeugt ausschließlich Ereignisse.
- Infrastruktur kennt keine externen Dienste.
- n8n verarbeitet sämtliche Ereignisse.
- Benachrichtigungen erfolgen ausschließlich über n8n.
- Neue Workflows können ergänzt werden, ohne bestehende Infrastruktur anzupassen.

---

# Zukünftige Erweiterungen

Das Event-System bildet die Grundlage für zukünftige Automatisierungen.

Geplante Erweiterungen:

- Backup-Rotation
- Monitoring
- Software-Updates
- Deployment-Pipelines
- Health Checks
- Sicherheitsbenachrichtigungen
- Projektautomatisierungen