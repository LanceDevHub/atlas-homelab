# Event Transport

Dieses Dokument beschreibt den Transport von Ereignissen innerhalb der Atlas-Plattform.

Es definiert, wie Infrastruktur-Komponenten Ereignisse erzeugen, lokal speichern und anschließend an die zentrale Workflow-Plattform weiterleiten.

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

Der Event-Transport besteht aus fünf Komponenten.

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

HTTP Webhook

        │

        ▼

n8n
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
- erzeugt Dateinamen,
- erstellt das JSON-Ereignis,
- legt das Ereignis in der Event Queue ab.

Sie kennt weder Transportprotokolle noch Workflow-Systeme.

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
├── 20260709T030001123456789.json
├── 20260709T030503987654321.json
└── ...
```

Dadurch bleiben Ereignisse auch nach einem Neustart des Systems erhalten.

---

## Event Dispatcher

Der Event Dispatcher verarbeitet alle Ereignisse innerhalb der Event Queue.

Für jedes Event wird ein HTTP-POST an den zentralen n8n-Webhook gesendet.

Nach erfolgreicher Verarbeitung wird die entsprechende Event-Datei gelöscht.

Schlägt die Übertragung fehl, verbleibt das Ereignis in der Queue und wird beim nächsten Durchlauf erneut verarbeitet.

Der Dispatcher wird regelmäßig über einen systemd Timer ausgeführt.

---

## Workflow-Plattform

Aktuell verwendet Atlas n8n als zentrale Workflow-Plattform.

n8n verarbeitet eingehende Ereignisse und entscheidet über die weitere Verarbeitung.

Beispiele:

- Discord-Benachrichtigung
- E-Mail
- Retry-Workflows
- Weitere Automatisierungen

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

HTTP POST

        │

        ▼

n8n Webhook

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

Die Dateinamen werden automatisch erzeugt und bestehen aus einem Zeitstempel mit Nanosekundenauflösung.

Dadurch sind sie chronologisch sortierbar und praktisch eindeutig.

Die Queue dient gleichzeitig als Persistenzschicht zwischen Infrastruktur und Workflow-Plattform.

---

# Fehlerbehandlung

Kann ein Ereignis nicht übertragen werden, verbleibt es unverändert in der Event Queue.

Mögliche Ursachen sind beispielsweise:

- n8n nicht erreichbar
- Netzwerkfehler
- HTTP-Fehler
- Workflow nicht verfügbar

Der Dispatcher versucht die Übertragung beim nächsten Durchlauf erneut.

Dadurch gehen keine Ereignisse verloren.

Das Erzeugen eines Ereignisses beeinflusst die Infrastruktur-Komponenten nicht.

---

# Transport

Das Event-Format ist vollständig unabhängig vom verwendeten Transportweg.

Aktuell verwendet Atlas HTTP-Webhooks zur Kommunikation mit n8n.

Zukünftige Transportwege könnten beispielsweise sein:

- MQTT
- Redis Streams
- RabbitMQ
- Apache Kafka

Die Infrastruktur-Komponenten müssen hierfür nicht angepasst werden.

---

# Architekturentscheidungen

Atlas trifft folgende Architekturentscheidungen.

- Infrastruktur-Komponenten erzeugen ausschließlich Ereignisse.
- Alle Ereignisse werden zunächst lokal gespeichert.
- Jedes Ereignis wird als einzelne JSON-Datei abgelegt.
- Die Event Queue dient als Puffer zwischen Infrastruktur und Workflow-Plattform.
- Die Event Library kennt keine Transportprotokolle.
- Der Event Dispatcher übernimmt ausschließlich den Transport.
- n8n verarbeitet ausschließlich eingehende Ereignisse.
- Ereignisse werden erst nach erfolgreicher Verarbeitung aus der Queue entfernt.

---

# Status

## Architektur

✅ Event Queue definiert

✅ Event Dispatcher definiert

✅ Transport definiert

## Implementierung

✅ Event Library implementiert

✅ Event Queue implementiert

✅ Event Dispatcher implementiert

✅ HTTP-Transport implementiert

✅ n8n integriert

✅ Discord integriert