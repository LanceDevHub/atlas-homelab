# Event Transport

Dieses Dokument beschreibt den Transport von Ereignissen innerhalb der Atlas-Plattform.

Es definiert, wie Infrastruktur-Komponenten Ereignisse erzeugen, lokal speichern und später an externe Workflow-Systeme weitergeleitet werden.

Die Struktur eines Ereignisses wird im Dokument

```text
event-format.md
```

beschrieben.

---

# Ziel

Der Event-Transport verfolgt folgende Ziele.

- Lose Kopplung zwischen Infrastruktur und Workflow-Plattform
- Zuverlässige Ereignisübertragung
- Wiederholbare Zustellung
- Lokale Zwischenspeicherung
- Unabhängigkeit vom Transportprotokoll
- Erweiterbarkeit für zukünftige Transportwege

---

# Architektur

Der Event-Transport besteht aus vier Komponenten.

```text
Infrastruktur

        │

        ▼

Event Library

        │

        ▼

Event Queue

        │

        ▼

Event Dispatcher

        │

        ▼

Workflow-Plattform
```

Jede Komponente besitzt genau eine Verantwortung.

---

# Komponenten

## Infrastruktur

Infrastruktur-Komponenten erzeugen Ereignisse.

Aktuell:

- Backup Engine
- Restore Engine
- Transfer Engine

Zukünftig:

- Monitoring
- Deployment
- Health Checks

Die Infrastruktur kennt ausschließlich die Event Library.

---

## Event Library

Die Event Library stellt die öffentliche API zum Erzeugen von Ereignissen bereit.

Aktuell umfasst sie folgende Funktionen:

- `event_emit`
- `event_payload`

Die Library

- erzeugt Zeitstempel,
- erstellt Dateinamen,
- erzeugt das JSON-Ereignis,
- legt das Ereignis in der Event Queue ab.

Sie kennt keine Transportprotokolle und keine Workflow-Systeme.

---

## Event Queue

Die Event Queue dient als lokale Zwischenspeicherung aller noch nicht verarbeiteten Ereignisse.

```text
/opt/atlas/events
```

Jedes Ereignis wird als einzelne JSON-Datei gespeichert.

Beispiel:

```text
events/
├── 20260704T030001123456789.json
├── 20260704T030503987654321.json
└── ...
```

Dadurch bleiben Ereignisse auch nach einem Neustart des Systems erhalten.

---

## Event Dispatcher

Der Event Dispatcher liest neue Ereignisse aus der Event Queue.

Er überträgt diese an die Workflow-Plattform.

Nach erfolgreicher Verarbeitung wird das Ereignis aus der Event Queue entfernt.

Der Dispatcher ist aktuell noch nicht implementiert.

---

## Workflow-Plattform

Die Workflow-Plattform verarbeitet eingehende Ereignisse.

Geplant ist aktuell:

- n8n

Die Workflow-Plattform entscheidet selbst, welche Aktionen ausgeführt werden.

---

# Ablauf

Ein Ereignis durchläuft folgende Schritte.

```text
backup.sh

        │

        ▼

event_emit()

        │

        ▼

Event Library

        │

        ▼

JSON-Datei

        │

        ▼

/opt/atlas/events

        │

        ▼

Event Dispatcher

        │

        ▼

HTTP

        │

        ▼

n8n

        │

        ▼

Discord / Mail / weitere Workflows
```

---

# Event Queue

Die Event Queue befindet sich unter

```text
/opt/atlas/events
```

Jede JSON-Datei repräsentiert genau ein Ereignis.

Die Dateinamen werden automatisch erzeugt und bestehen aus einem UTC-Zeitstempel mit Nanosekundenauflösung.

Dadurch sind sie chronologisch sortierbar und praktisch eindeutig.

---

# Fehlerbehandlung

Kann ein Ereignis nicht übertragen werden, verbleibt es in der Event Queue.

Der Dispatcher versucht die Übertragung später erneut.

Dadurch gehen keine Ereignisse verloren.

Das Erzeugen eines Ereignisses beeinflusst die Infrastruktur-Komponenten nicht.

---

# Transport

Das Event-Format ist vollständig unabhängig vom Transportweg.

Aktuell existiert lediglich die lokale Event Queue.

Geplante Transportwege:

- HTTP / HTTPS
- MQTT
- Redis
- RabbitMQ

Die Infrastruktur-Komponenten müssen hierfür nicht angepasst werden.

---

# Architekturentscheidungen

Atlas trifft folgende Architekturentscheidungen.

- Infrastruktur-Komponenten erzeugen ausschließlich Ereignisse.
- Alle Ereignisse werden zunächst lokal gespeichert.
- Jedes Ereignis wird als einzelne JSON-Datei abgelegt.
- Die Event Queue dient als Puffer zwischen Infrastruktur und Workflow-Plattform.
- Die Event Library kennt keine Transportprotokolle.
- Der Event Dispatcher übernimmt ausschließlich die Übertragung.
- Die Workflow-Plattform verarbeitet ausschließlich eingehende Ereignisse.

---

# Status

## Architektur

✅ Event Queue definiert

✅ Event Dispatcher definiert

✅ Transport definiert

## Implementierung

✅ Event Library implementiert

✅ Event Queue implementiert

⬜ Event Dispatcher implementieren

⬜ HTTP-Transport implementieren

⬜ n8n anbinden