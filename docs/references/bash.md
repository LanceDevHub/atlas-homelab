# Bash-Referenz

Diese Referenz beschreibt die wichtigsten Bash-Konstrukte und Befehle, die innerhalb der Atlas-Skripte verwendet werden.

Sie dient als Nachschlagewerk für die Wartung und Erweiterung der Backup- und Restore-Skripte.

Die Referenz ist bewusst auf die in Atlas verwendeten Konzepte beschränkt und ersetzt kein vollständiges Bash-Handbuch.

---

# Shebang

```bash
#!/usr/bin/env bash
```

Startet das Skript mit der Bash-Interpreter-Version, die im aktuellen System verfügbar ist.

Dadurch wird nicht auf einen festen Installationspfad wie `/bin/bash` angewiesen.

---

# Strict Mode

```bash
set -Eeuo pipefail
```

Aktiviert einen strengen Fehlermodus und verhindert viele typische Fehler in Shell-Skripten.

| Option | Bedeutung |
|----------|-----------|
| `-e` | Beendet das Skript sofort, wenn ein Befehl fehlschlägt. |
| `-E` | Vererbt Error-Traps auch an Funktionen und Subshells. |
| `-u` | Nicht gesetzte Variablen führen zu einem Fehler. |
| `pipefail` | Eine Pipeline schlägt fehl, sobald ein Teil der Pipeline fehlschlägt. |

---

# readonly

```bash
readonly BACKUP_ROOT="/opt/atlas/backups"
```

Deklariert eine Konstante.

Ein späteres Überschreiben der Variable führt zu einem Fehler.

---

# Variablen

Variablen werden ohne Typ deklariert.

```bash
BACKUP_DIR="/opt/atlas/backups"
```

Auf Variablen wird mit `${...}` zugegriffen.

```bash
echo "${BACKUP_DIR}"
```

Die geschweiften Klammern verbessern die Lesbarkeit und verhindern Mehrdeutigkeiten.

---

# Parameter Expansion

```bash
"${1:-}"
```

Liest den ersten Kommandozeilenparameter.

Ist kein Parameter vorhanden, wird stattdessen ein leerer String verwendet.

Beispiel:

```bash
restore.sh /backup/latest
```

Dann gilt:

```text
$1 = /backup/latest
```

---

# Command Substitution

```bash
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
```

Speichert die Ausgabe eines Befehls in einer Variable.

---

# Arrays

Mehrere zusammengehörige Werte können in einem Array gespeichert werden.

```bash
readonly REQUIRED_ENV_FILES=(
    postgres
    n8n
    traefik
)
```

Auf alle Elemente wird mit

```bash
"${REQUIRED_ENV_FILES[@]}"
```

zugegriffen.

---

# Quoting

Variablen werden grundsätzlich in Anführungszeichen verwendet.

```bash
"${BACKUP_DIR}"
```

Dadurch bleiben Leerzeichen und Sonderzeichen erhalten.

Dies verhindert zahlreiche Fehler bei Datei- und Verzeichnisnamen.

---

# Test-Ausdrücke

Bash verwendet `[[ ... ]]` zur Auswertung von Bedingungen.

## Datei vorhanden

```bash
[[ -f file ]]
```

## Verzeichnis vorhanden

```bash
[[ -d directory ]]
```

## Datei vorhanden und nicht leer

```bash
[[ -s postgres.dump ]]
```

## Zeichenkette leer

```bash
[[ -z "${value}" ]]
```

## Zeichenkette nicht leer

```bash
[[ -n "${value}" ]]
```

---

# if

```bash
if [[ -f file ]]; then
    ...
else
    ...
fi
```

Führt Befehle abhängig von einer Bedingung aus.

---

# Schleifen

Mehrere Werte können mit einer `for`-Schleife verarbeitet werden.

```bash
for service in "${REQUIRED_ENV_FILES[@]}"; do
    ...
done
```

Ebenso können Dateien durchlaufen werden.

```bash
for env_file in "${COMPOSE_DIR}"/*/.env; do
    ...
done
```

---

# Funktionen

Funktionen fassen zusammengehörige Aufgaben zusammen.

```bash
backup_postgres() {
    ...
}
```

Dadurch werden Skripte übersichtlicher und leichter wartbar.

---

# Lokale Variablen

Variablen können auf eine Funktion beschränkt werden.

```bash
local errors=0
```

Die Variable existiert ausschließlich innerhalb dieser Funktion.

---

# Arithmetische Ausdrücke

Bash unterstützt einfache Ganzzahlarithmetik.

```bash
((errors++))
```

Erhöht den Wert der Variable um eins.

Ebenso möglich:

```bash
((errors += 2))
((counter--))
```

---

# Exit-Status

```bash
exit 0
```

Beendet das Skript erfolgreich.

```bash
exit 1
```

Beendet das Skript mit einem Fehler.

---

# Here Document

Ein Here Document übergibt mehrere Zeilen an einen Befehl.

Beispiel:

```bash
cat > backup.info <<EOF
BACKUP_VERSION=1
HOSTNAME=$(hostname)
EOF
```

Ebenso wird diese Technik verwendet, um SQL-Befehle an PostgreSQL zu senden.

```bash
psql <<EOF
SELECT version();
EOF
```

---

# source

```bash
source postgres/.env
```

Führt eine Datei im aktuellen Shell-Prozess aus.

Dadurch werden Variablen in die aktuelle Shell geladen.

---

# set -a

```bash
set -a
source .env
set +a
```

Exportiert automatisch alle geladenen Variablen als Umgebungsvariablen.

Dadurch stehen sie Programmen wie `pg_dump`, `pg_restore` oder `psql` zur Verfügung.

---

# shopt

```bash
shopt -s nullglob
```

Aktiviert die Option `nullglob`.

Falls ein Dateimuster keine Treffer besitzt, wird daraus eine leere Liste.

Ohne `nullglob` würde beispielsweise

```text
*.env
```

als normaler String behandelt werden.

Nach der Verwendung wird die ursprüngliche Einstellung wiederhergestellt.

```bash
shopt -u nullglob
```

---

# mkdir -p

```bash
mkdir -p /opt/atlas/backups
```

Erstellt ein Verzeichnis inklusive aller fehlenden Elternverzeichnisse.

Existiert das Verzeichnis bereits, entsteht kein Fehler.

---

# cp -a

```bash
cp -a source destination
```

Kopiert Dateien im Archivmodus.

Dabei bleiben erhalten:

- Berechtigungen
- Eigentümer (wenn möglich)
- Zeitstempel
- symbolische Links

Diese Option wird für Backup und Restore verwendet.

---

# rm -rf

```bash
rm -rf directory
```

Löscht Dateien und Verzeichnisse rekursiv ohne Rückfrage.

Diese Option sollte mit Vorsicht verwendet werden.

Im Restore wird sie verwendet, um vorhandene Daten vollständig durch den Backup-Inhalt zu ersetzen.

---

# Docker Compose

Container starten

```bash
docker compose up -d
```

Container stoppen

```bash
docker compose down
```

Status laufender Container prüfen

```bash
docker compose ps --status running -q
```

---

# PostgreSQL-Werkzeuge

## pg_dump

```bash
pg_dump
```

Erstellt ein Backup einer PostgreSQL-Datenbank.

---

## pg_restore

```bash
pg_restore
```

Stellt ein zuvor erstelltes PostgreSQL-Backup wieder her.

---

## psql

```bash
psql
```

Führt SQL-Befehle aus oder verbindet sich interaktiv mit einer PostgreSQL-Datenbank.

---

## pg_isready

```bash
pg_isready
```

Prüft, ob ein PostgreSQL-Server erreichbar und betriebsbereit ist.

---

# Zusammenfassung

Die Atlas-Skripte verwenden bewusst nur einen kleinen Teil der Bash-Funktionalität.

Der Fokus liegt auf:

- klarer Lesbarkeit
- reproduzierbarem Verhalten
- robuster Fehlerbehandlung
- einfacher Wartbarkeit

Neue Skripte sollten denselben Stil und dieselben Konventionen verwenden.