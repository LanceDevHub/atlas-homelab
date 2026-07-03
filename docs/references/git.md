# Git

---

# Repository-Status

## Status anzeigen

```bash
git status
```

Zeigt den aktuellen Zustand des Repositorys.

---

## Änderungen anzeigen

```bash
git diff
```

Zeigt nicht gespeicherte Änderungen.

---

## Commit-Historie

```bash
git log
```

Kurze Übersicht:

```bash
git log --oneline --decorate
```

---

# Änderungen committen

## Dateien hinzufügen

Alle Änderungen:

```bash
git add .
```

Einzelne Datei:

```bash
git add <datei>
```

---

## Commit erstellen

```bash
git commit -m "Commit-Nachricht"
```

---

## Änderungen hochladen

```bash
git push
```

---

# Repository klonen

```bash
git clone <repository-url>
```

---

# Remote verwalten

## Aktuelle Remotes anzeigen

```bash
git remote -v
```

---

## Remote hinzufügen

```bash
git remote add origin <repository-url>
```

---

## Remote ändern

```bash
git remote set-url origin <repository-url>
```

---

# Branches

## Branches anzeigen

```bash
git branch
```

Remote-Branches:

```bash
git branch -a
```

---

## Neuen Branch erstellen

```bash
git checkout -b <branch-name>
```

---

## Branch wechseln

```bash
git checkout <branch-name>
```

---

# Tags

## Alle Tags anzeigen

```bash
git tag
```

---

## Annotierten Tag erstellen

```bash
git tag -a v1.0.0 -m "Beschreibung"
```

---

## Tag veröffentlichen

```bash
git push origin v1.0.0
```

---

## Alle Tags veröffentlichen

```bash
git push --tags
```

---

# Repository aktualisieren

## Änderungen herunterladen

```bash
git fetch
```

---

## Änderungen herunterladen und übernehmen

```bash
git pull
```

---

# Fehleranalyse

## Aktuellen Branch anzeigen

```bash
git branch
```

---

## Letzte Commits

```bash
git log --oneline -10
```

---

## Remote prüfen

```bash
git remote -v
```

---

## Ignorierte Dateien prüfen

```bash
git status --ignored
```

---

# Atlas-Workflow

## Änderungen veröffentlichen

1. Repository-Status prüfen

```bash
git status
```

2. Änderungen hinzufügen

```bash
git add .
```

3. Commit erstellen

```bash
git commit -m "Commit-Nachricht"
```

4. Änderungen hochladen

```bash
git push
```

---

## Neue Version veröffentlichen

1. Änderungen committen

```bash
git status
git add .
git commit -m "Beschreibung"
git push
```

2. Tag erstellen

```bash
git tag -a vX.Y.Z -m "Beschreibung"
```

3. Tag veröffentlichen

```bash
git push origin vX.Y.Z
```