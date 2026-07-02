# Linux Referenz

Diese Datei dient als persönliche Referenz für häufig verwendete Linux-Befehle innerhalb der Atlas-Plattform.

Jeder Befehl wird mit seinem Zweck, den verwendeten Parametern und typischen Einsatzszenarien dokumentiert.

---

# Navigation

## Aktuelles Verzeichnis anzeigen

```bash
pwd
```

### Zweck

Zeigt das aktuelle Arbeitsverzeichnis an.

---

## Verzeichnisinhalt anzeigen

```bash
ls
```

### Häufige Optionen

| Option | Bedeutung |
| ------- | --------- |
| -l | Detaillierte Ansicht |
| -a | Versteckte Dateien anzeigen |
| -h | Größen lesbar darstellen |

### Beispiel

```bash
ls -lah
```

---

## Verzeichnis wechseln

```bash
cd <pfad>
```

### Beispiele

```bash
cd /opt/atlas
```

```bash
cd ..
```

```bash
cd ~
```

---

# Dateien und Verzeichnisse

## Datei kopieren

```bash
cp quelle ziel
```

### Beispiel

```bash
cp compose.yaml compose.backup.yaml
```

---

## Verzeichnis kopieren

```bash
cp -r quelle ziel
```

### Parameter

| Option | Bedeutung |
| ------- | --------- |
| -r | Rekursiv (inklusive Unterordner) |

---

## Datei oder Verzeichnis verschieben

```bash
mv quelle ziel
```

### Beispiele

```bash
mv atlas atlas_old
```

```bash
mv test.txt backup/
```

### Zweck

- Datei verschieben
- Datei umbenennen
- Verzeichnis umbenennen

---

## Datei löschen

```bash
rm datei
```

---

## Verzeichnis löschen

```bash
rm -r verzeichnis
```

### Parameter

| Option | Bedeutung |
| ------- | --------- |
| -r | Rekursiv löschen |
| -f | Ohne Rückfrage löschen |

### Beispiel

```bash
rm -rf atlas_old
```

---

## Verzeichnis erstellen

```bash
mkdir verzeichnis
```

### Mehrere Ebenen erstellen

```bash
mkdir -p compose/redis
```

---

# Dateien anzeigen

## Datei ausgeben

```bash
cat datei
```

---

## Datei seitenweise lesen

```bash
less datei
```

---

## Anfang einer Datei

```bash
head datei
```

---

## Ende einer Datei

```bash
tail datei
```

### Logs verfolgen

```bash
tail -f logfile.log
```

---

# Berechtigungen

## Besitzer ändern

```bash
sudo chown benutzer:gruppe datei
```

### Beispiel

```bash
sudo chown -R lenny:lenny /opt/atlas
```

### Parameter

| Option | Bedeutung |
| ------- | --------- |
| -R | Rekursiv |

---

## Rechte ändern

```bash
chmod rechte datei
```

### Beispiel

```bash
chmod 600 ~/.ssh/authorized_keys
```

```bash
chmod 700 ~/.ssh
```

---

## Dateirechte anzeigen

```bash
ls -l
```

---

# Suchen

## Dateien suchen

```bash
find . -name "*.yaml"
```

---

## Text suchen

```bash
grep suchbegriff datei
```

### Beispiel

```bash
grep postgres compose.yaml
```

---

# Systeminformationen

## Speicherplatz

```bash
df -h
```

---

## Ordnergröße

```bash
du -sh ordner
```

---

## Prozesse anzeigen

```bash
ps aux
```

---

## Laufende Dienste

```bash
systemctl status dienst
```

### Beispiel

```bash
systemctl status ssh
```

---

# Netzwerk

## IP-Adressen anzeigen

```bash
ip addr
```

---

## Hostname anzeigen

```bash
hostname
```

---

## Hostname setzen

```bash
sudo hostnamectl set-hostname atlas
```

---

# Archive

## ZIP entpacken

```bash
unzip datei.zip
```

---

## tar.gz entpacken

```bash
tar -xzf archiv.tar.gz
```

---

# Nützliche Befehle

## Baumstruktur anzeigen

```bash
tree
```

---

## Verlauf anzeigen

```bash
history
```

---

## Benutzer anzeigen

```bash
whoami
```

---

## Root-Rechte für einen Befehl

```bash
sudo befehl
```

### Zweck

Führt einen einzelnen Befehl mit Administratorrechten aus.