# Event Transport

Dieses Dokument beschreibt den Transport von Ereignissen innerhalb der Atlas-Plattform.

Es definiert, wie Infrastruktur-Komponenten Ereignisse bereitstellen, wie diese zwischengespeichert werden und wie sie an die Workflow-Plattform weitergeleitet werden.

Die Struktur der Ereignisse wird im Dokument

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
- Unabhängigkeit vom Transportprotokoll
- Erweiterbarkeit für zukünftige Transportwege

---

# Architektur

Der Event-Transport besteht aus vier Komponenten.

```text
Infrastruktur

↓

Event Library

↓

Event Queue

↓

Event Dispatcher

↓

Workflow-Plattform
```

Jede Komponente besitzt genau eine Verantwortung.

---

# Komponenten

## Infrastruktur

Infrastruktur-Komponenten erzeugen Ereignisse.

Beispiele:

- Backup Engine
- Restore Engine
- Transfer Engine
- Monitoring

Sie kennen ausschließlich die Event Library.

---

## Event Library

Die Event Library erzeugt standardisierte JSON-Ereignisse.

Sie validiert den Aufbau eines Events und legt dieses in der Event Queue ab.

Die Event Library kennt keine Transportprotokolle.

---

## Event Queue

Die Event Queue dient als lokale Zwischenspeicherung aller noch nicht verarbeiteten Ereignisse.

```text
/opt/atlas/events
```

Jedes Event wird als einzelne JSON-Datei gespeichert.

Dadurch bleiben Ereignisse auch nach einem Neustart des Systems erhalten.

---

## Event Dispatcher

Der Event Dispatcher liest neue Ereignisse aus der Event Queue.

Er überträgt diese an die Workflow-Plattform.

Nach erfolgreicher Verarbeitung wird das Ereignis aus der Event Queue entfernt.

---

## Workflow-Plattform

Die Workflow-Plattform verarbeitet eingehende Ereignisse.

Aktuell:

- n8n

Die Workflow-Plattform entscheidet selbst, welche Aktionen ausgeführt werden.

---

# Ablauf

Ein Ereignis durchläuft folgende Schritte.

```text
Backup Engine

↓

Event Library

↓

JSON-Datei

↓

Event Queue

↓

Event Dispatcher

↓

HTTP Request

↓

n8n

↓

Discord
```

---

# Event Queue

Die Event Queue befindet sich unter

```text
/opt/atlas/events
```

Beispiel:

```text
events/
├── 20260704T030001Z.json
├── 20260704T030502Z.json
└── ...
```

Jede Datei enthält genau ein Ereignis.

---

# Fehlerbehandlung

Kann ein Ereignis nicht übertragen werden, verbleibt es in der Event Queue.

Der Dispatcher versucht die Übertragung später erneut.

Dadurch gehen keine Ereignisse verloren.

---

# Transport

Das Event-Format ist unabhängig vom Transportweg.

Aktuell erfolgt die Übertragung über HTTP.

Zukünftig sind weitere Transportwege möglich.

Beispiele:

- HTTPS
- MQTT
- Redis
- RabbitMQ

Die Infrastruktur-Komponenten müssen hierfür nicht angepasst werden.

---

# Architekturentscheidungen

Atlas trifft folgende Architekturentscheidungen.

- Infrastruktur-Komponenten erzeugen ausschließlich Ereignisse.
- Ereignisse werden zunächst lokal gespeichert.
- Jedes Ereignis wird als einzelne JSON-Datei abgelegt.
- Die Event Queue dient als Puffer zwischen Infrastruktur und Workflow-Plattform.
- Der Event Dispatcher übernimmt ausschließlich die Übertragung.
- Die Workflow-Plattform verarbeitet ausschließlich eingehende Ereignisse.

---

# Status

## Architektur

✅ Event Queue definiert

✅ Event Dispatcher definiert

✅ Transport definiert

## Implementierung

⬜ Event Library implementieren

⬜ Event Queue implementieren

⬜ Event Dispatcher implementieren

⬜ HTTP-Transport implementieren

⬜ n8n anbinden