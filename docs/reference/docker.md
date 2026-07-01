---

# Atlas-Workflows

## Änderungen an einer Compose-Datei übernehmen

### 1. Konfiguration prüfen

```bash
docker compose config
```

### 2. Container stoppen

```bash
docker compose down
```

### 3. Container starten

```bash
docker compose up -d
```

### 4. Logs kontrollieren

```bash
docker compose logs
```

### 5. Status prüfen

```bash
docker compose ps
```

---

## Änderungen an einer `.env` übernehmen

Nach Änderungen an einer `.env` muss der Container neu erstellt werden.

```bash
docker compose down
docker compose up -d
```

---

## Fehleranalyse

### Laufende Container prüfen

```bash
docker compose ps
```

### Logs anzeigen

```bash
docker compose logs
```

### Live-Logs verfolgen

```bash
docker compose logs -f
```

Parameter:

| Parameter | Bedeutung                             |
| --------- | ------------------------------------- |
| -f        | Zeigt neue Logeinträge fortlaufend an |

---

## Container-Konfiguration prüfen

```bash
docker compose config
```

Verwende diesen Befehl immer vor dem ersten Start oder nach Änderungen an der `compose.yaml`.

---

## Container neu starten

```bash
docker compose restart
```

Verwenden, wenn lediglich ein Neustart erforderlich ist und sich weder `compose.yaml` noch `.env` geändert haben.

---

## Kompletten Docker-Status prüfen

```bash
docker ps
docker network ls
docker volume ls
docker image ls
```

Damit erhält man einen schnellen Überblick über:

- laufende Container
- vorhandene Netzwerke
- persistente Volumes
- lokale Images
