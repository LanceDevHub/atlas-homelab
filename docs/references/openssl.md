# OpenSSL

---

# Zertifikat erstellen

## Selbstsigniertes Zertifikat mit Konfigurationsdatei erstellen

```bash
openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:4096 \
  -keyout atlas.key \
  -out atlas.crt \
  -config atlas.cnf \
  -extensions req_ext
```

Verwendet die OpenSSL-Konfigurationsdatei (`atlas.cnf`) zur Erstellung eines selbstsignierten TLS-Zertifikats.

---

# Zertifikate anzeigen

## Alle Zertifikatsinformationen anzeigen

```bash
openssl x509 -in atlas.crt -text -noout
```

---

## Gültigkeitszeitraum anzeigen

```bash
openssl x509 -in atlas.crt -dates -noout
```

---

## Subject anzeigen

```bash
openssl x509 -in atlas.crt -subject -noout
```

---

## Issuer anzeigen

```bash
openssl x509 -in atlas.crt -issuer -noout
```

---

## SHA256-Fingerprint anzeigen

```bash
openssl x509 -in atlas.crt -fingerprint -sha256 -noout
```

---

# Private Key prüfen

```bash
openssl rsa -in atlas.key -check
```

---

# Subject Alternative Names (SAN)

```bash
openssl x509 -in atlas.crt -text -noout
```

Im Abschnitt

```text
X509v3 Subject Alternative Name
```

werden alle Hostnamen angezeigt, für die das Zertifikat gültig ist.

---

# Zertifikat testen

## HTTPS-Verbindung prüfen

```bash
openssl s_client -connect n8n.home.arpa:443
```

---

## Zertifikatskette anzeigen

```bash
openssl s_client -connect n8n.home.arpa:443 -showcerts
```

---

# Wichtige Dateien

```text
atlas.cnf   -> OpenSSL-Konfiguration
atlas.key   -> Privater Schlüssel
atlas.crt   -> Zertifikat
```

---

# Atlas-Workflow

## Zertifikat ändern

1. `atlas.cnf` anpassen
2. Zertifikat neu erstellen

```bash
openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:4096 \
  -keyout atlas.key \
  -out atlas.crt \
  -config atlas.cnf \
  -extensions req_ext
```

3. Traefik neu starten

```bash
docker compose up -d
```

4. Zertifikat prüfen

```bash
openssl x509 -in atlas.crt -text -noout
```