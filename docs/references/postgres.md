---

# Atlas-Workflows

## Neue Anwendung mit PostgreSQL vorbereiten

Dieser Workflow beschreibt die Standardvorgehensweise, um eine neue Anwendung in die PostgreSQL-Infrastruktur von Atlas zu integrieren.

### 1. Als Administrator anmelden

```bash
docker exec -it postgres-postgres-1 psql -U atlas -d postgres
```

### 2. Benutzer erstellen

```sql
CREATE USER <anwendung> WITH PASSWORD '<passwort>';
```

Beispiel:

```sql
CREATE USER n8n WITH PASSWORD 'mein-passwort';
```

### 3. Datenbank erstellen

```sql
CREATE DATABASE <anwendung> OWNER <anwendung>;
```

Beispiel:

```sql
CREATE DATABASE n8n OWNER n8n;
```

### 4. Benutzer kontrollieren

```sql
\du
```

### 5. Datenbanken kontrollieren

```sql
\l
```

### 6. Anwendung konfigurieren

Die Zugangsdaten werden anschließend in der `.env` der jeweiligen Anwendung hinterlegt.

Beispiel:

```env
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=<passwort>
```

---

## Verbindung testen

Mit der Anwendung verbinden oder alternativ direkt über die Konsole:

```bash
docker exec -it postgres-postgres-1 psql -U n8n -d n8n
```

---

## Passwort eines Benutzers ändern

```sql
ALTER USER benutzername WITH PASSWORD 'neues-passwort';
```

Danach muss die entsprechende `.env` der Anwendung ebenfalls aktualisiert werden.

---

## Datenbank entfernen

> Achtung: Dieser Vorgang löscht alle enthaltenen Daten.

```sql
DROP DATABASE datenbank;
```

Optional anschließend den Benutzer entfernen:

```sql
DROP USER benutzername;
```
