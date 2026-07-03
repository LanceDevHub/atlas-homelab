# Traefik

## Zweck

Traefik ist der zentrale Reverse Proxy der Atlas-Plattform.

Er bildet den einzigen öffentlichen Einstiegspunkt für sämtliche Webanwendungen und übernimmt die Verarbeitung eingehender HTTP- und HTTPS-Anfragen.

Zu seinen Aufgaben gehören insbesondere:

- Routing anhand des Hostnamens
- TLS-Terminierung (HTTPS)
- HTTP-zu-HTTPS-Weiterleitung
- Bereitstellung zentraler HTTP Security Header
- Automatische Erkennung veröffentlichter Docker-Container

Dadurch müssen einzelne Dienste keine eigene HTTPS-Konfiguration oder Webserver betreiben.

---

# Architektur

Traefik wird ausschließlich als Docker-Container betrieben und ist Mitglied des gemeinsamen Docker-Netzwerks

```text
atlas-network
```

Alle Webanwendungen kommunizieren ausschließlich mit Traefik.

```text
                 Browser
                     │
                 HTTP / HTTPS
                     │
                     ▼
                 Traefik
                     │
             atlas-network
      ┌──────────────┴──────────────┐
      │                             │
    n8n                     weitere Dienste
```

Traefik bildet damit den zentralen Einstiegspunkt der gesamten Webplattform.

---

# Anfragefluss

Eine HTTPS-Anfrage durchläuft innerhalb der Atlas-Plattform folgenden Weg:

```text
Browser
    │
 HTTPS
    │
    ▼
Traefik
(TLS Termination)
    │
 HTTP
    │
    ▼
Backend Service
```

Die TLS-Verschlüsselung endet an Traefik.

Die Kommunikation zwischen Traefik und den Containern erfolgt anschließend unverschlüsselt über das isolierte Docker-Netzwerk.

Dadurch müssen Backend-Dienste selbst kein HTTPS unterstützen.

---

# Docker-Integration

Traefik verwendet den Docker Provider.

Dadurch erkennt Traefik automatisch:

- laufende Container
- Docker Labels
- Netzwerke
- veröffentlichte Dienste

Neue Dienste müssen lediglich Docker Labels definieren.

Eine zentrale Routing-Konfiguration ist dadurch nicht erforderlich.

---

# Docker Provider

Der Docker Provider überwacht kontinuierlich die Docker Engine.

Sobald ein neuer Container gestartet wird, liest Traefik dessen Docker Labels aus und erstellt daraus automatisch:

- Router
- Services
- Routingregeln

Nur Container mit

```text
traefik.enable=true
```

werden veröffentlicht.

Alle anderen Container bleiben standardmäßig unsichtbar.

---

# File Provider

Neben Docker verwendet Atlas den File Provider.

Dieser stellt Konfigurationen bereit, die keinem einzelnen Container gehören.

Aktuell werden darüber verwaltet:

- TLS-Zertifikate
- HTTP Security Header

Die Konfiguration befindet sich unter

```text
/opt/atlas/compose/traefik/config
```

---

# EntryPoints

EntryPoints definieren, auf welchen Ports Traefik Anfragen entgegennimmt.

## web

```text
Port 80
```

Der EntryPoint dient ausschließlich dazu, HTTP-Anfragen entgegenzunehmen und automatisch auf HTTPS umzuleiten.

Eine direkte Bereitstellung von Anwendungen erfolgt darüber nicht.

---

## websecure

```text
Port 443
```

Dieser EntryPoint verarbeitet sämtliche HTTPS-Anfragen.

Alle veröffentlichten Dienste verwenden ausschließlich diesen EntryPoint.

---

# Routing

Traefik verarbeitet eingehende Anfragen in mehreren Schritten.

```text
Request
    │
    ▼
Router
    │
Middleware
    │
Service
```

---

## Router

Ein Router entscheidet anhand definierter Regeln, welcher Dienst eine Anfrage verarbeiten soll.

In Atlas erfolgt das Routing über den Hostnamen.

Beispiel:

```text
n8n.home.arpa
```

↓

```text
n8n
```

---

## Middleware

Middlewares verändern oder erweitern Anfragen und Antworten.

Aktuell verwendet Atlas eine zentrale Middleware für HTTP Security Header.

Sie wird über den File Provider bereitgestellt und von allen veröffentlichten Diensten genutzt.

---

## Services

Ein Service beschreibt den eigentlichen Zielcontainer.

Bei n8n wird beispielsweise der interne Container-Port

```text
5678
```

verwendet.

---

# TLS

Traefik übernimmt die vollständige TLS-Terminierung.

Backend-Dienste benötigen daher keine eigene HTTPS-Konfiguration.

---

## Zertifikate

TLS-Zertifikate werden zentral gespeichert.

```text
/opt/atlas/certs
```

Aktuell werden verwendet:

```text
atlas.crt
atlas.key
```

Traefik lädt diese Zertifikate über den File Provider.

---

## TLS-Terminierung

Die TLS-Verbindung endet an Traefik.

Innerhalb des Docker-Netzwerks kommunizieren die Dienste weiterhin per HTTP.

Dies reduziert den Konfigurationsaufwand erheblich und ermöglicht eine zentrale Verwaltung sämtlicher Zertifikate.

---

## HTTP → HTTPS

Alle HTTP-Anfragen werden automatisch dauerhaft auf HTTPS umgeleitet.

```text
http://n8n.home.arpa
            │
            ▼
301 Redirect
            │
            ▼
https://n8n.home.arpa
```

Dadurch werden sämtliche Webanwendungen ausschließlich verschlüsselt bereitgestellt.

---

# HTTP Security Header

Traefik stellt zentrale HTTP Security Header bereit.

Aktuell werden verwendet:

| Header | Zweck |
| ------- | ----- |
| Strict-Transport-Security | Erzwingt zukünftige HTTPS-Verbindungen |
| X-Content-Type-Options | Verhindert MIME-Type-Sniffing |
| X-Frame-Options | Schutz vor Clickjacking |
| Referrer-Policy | Begrenzt übertragene Referrer-Informationen |

Die Header werden einmalig in Traefik definiert und gelten automatisch für alle veröffentlichten Dienste.

---

# Docker Labels

Die Veröffentlichung einzelner Dienste erfolgt vollständig über Docker Labels.

Ein Dienst definiert dort unter anderem:

- ob er veröffentlicht werden soll
- unter welchem Hostnamen
- welcher EntryPoint verwendet wird
- ob TLS aktiviert ist
- welcher interne Port angesprochen wird

Dadurch beschreibt jeder Dienst seine eigene Veröffentlichung selbst.

---

# Docker Socket

Traefik erhält ausschließlich lesenden Zugriff auf den Docker Socket.

```text
/var/run/docker.sock
```

Dadurch kann Traefik:

- Container erkennen
- Docker Labels lesen
- Router erzeugen
- Services erzeugen

Der Docker Socket wird ausschließlich read-only eingebunden.

---

# Architekturentscheidungen

## Zentraler Reverse Proxy

Atlas besitzt genau einen öffentlichen Einstiegspunkt.

Alle Webanwendungen werden ausschließlich über Traefik veröffentlicht.

Dadurch existiert nur eine zentrale Stelle für Routing und Sicherheitsfunktionen.

---

## TLS-Terminierung

HTTPS wird ausschließlich von Traefik verarbeitet.

Backend-Dienste kommunizieren intern weiterhin unverschlüsselt über das isolierte Docker-Netzwerk.

Dies reduziert die Komplexität der einzelnen Dienste erheblich.

---

## Automatische Service-Erkennung

Traefik erkennt neue Dienste automatisch über Docker Labels.

Neue Anwendungen können dadurch integriert werden, ohne eine zentrale Routing-Datei anpassen zu müssen.

---

## Zentrale Sicherheitsfunktionen

HTTPS, HTTP-Weiterleitungen sowie HTTP Security Header werden ausschließlich in Traefik konfiguriert.

Dadurch erhalten alle veröffentlichten Dienste automatisch dieselben Sicherheitsstandards.

---

## Trennung statischer und dynamischer Konfiguration

Traefik unterscheidet zwischen statischer und dynamischer Konfiguration.

Die statische Konfiguration erfolgt innerhalb der Compose-Datei und definiert unter anderem:

- Provider
- EntryPoints
- Ports
- Logging

Die dynamische Konfiguration wird über den File Provider bereitgestellt und enthält aktuell:

- TLS-Zertifikate
- HTTP Security Header

Diese Trennung verbessert die Wartbarkeit und Erweiterbarkeit der Infrastruktur.

---

# Status

✅ Traefik erfolgreich integriert

✅ Docker Provider eingerichtet

✅ File Provider eingerichtet

✅ HTTPS vollständig integriert

✅ TLS-Terminierung eingerichtet

✅ HTTP-zu-HTTPS-Weiterleitung aktiviert

✅ HTTP Security Header zentral konfiguriert

✅ Dashboard über HTTPS erreichbar