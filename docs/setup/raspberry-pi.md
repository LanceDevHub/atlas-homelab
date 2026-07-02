# Atlas HomeLab – Raspberry Pi Setup

> Dokumentation der Grundinstallation und Basiskonfiguration des Raspberry Pi 5 als Hostsystem der Atlas-Plattform.

---

# Ziel

Der Raspberry Pi bildet die Hardware- und Betriebssystembasis von Atlas.

Diese Dokumentation beschreibt alle Schritte, die zur Einrichtung des Hostsystems durchgeführt wurden.

---

# Aktueller Stand

## Betriebssystem

- Raspberry Pi OS installiert
- System vollständig aktualisiert
- Headless-Betrieb eingerichtet
- Hostname auf `atlas` gesetzt

## Netzwerk

- SSH eingerichtet
- SSH-Schlüssel konfiguriert
- Passwort-Authentifizierung deaktiviert
- Root-Login deaktiviert
- Tailscale eingerichtet
- UFW-Firewall aktiviert

## Container-Plattform

- Docker Engine installiert
- Docker Compose Plugin installiert
- Docker-Gruppe konfiguriert
- Docker erfolgreich getestet

## Infrastruktur

- Atlas-Verzeichnisstruktur erstellt
- Docker-Netzwerk `atlas-network` eingerichtet
- Traefik integriert
- PostgreSQL integriert
- n8n integriert

---

# 1. System aktualisieren

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo reboot
```

---

# 2. Headless-Modus

```bash
systemctl get-default
sudo systemctl set-default multi-user.target
sudo reboot
```

Optional:

```bash
sudo systemctl isolate multi-user.target
```

---

# 3. Hostname ändern

```bash
sudo hostnamectl set-hostname atlas
sudo nano /etc/hosts
sudo reboot
hostname
```

`/etc/hosts`

```text
127.0.1.1 atlas
```

---

# 4. SSH

```bash
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh
hostname -I
```

---

# 5. Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
tailscale status
ip addr show tailscale0
```

---

# 6. SSH-Schlüssel

Windows:

```powershell
ls ~/.ssh
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh lenny@atlas "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

Pi:

```bash
ls -la ~/.ssh
cat ~/.ssh/authorized_keys
```

---

# 7. SSH absichern

Datei:

```bash
sudo nano /etc/ssh/sshd_config.d/99-hardening.conf
```

Inhalt:

```text
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin no
```

Prüfen:

```bash
sudo sshd -t
sudo systemctl restart ssh
sudo sshd -T | grep -E 'passwordauthentication|pubkeyauthentication|permitrootlogin'
```

---

# 8. UFW

```bash
sudo apt install ufw -y
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status verbose
```

---

# Erreichte Sicherheitsziele

- SSH ausschließlich per Public-Key
- Passwort-Authentifizierung deaktiviert
- Root-Login deaktiviert
- UFW-Firewall aktiviert
- Tailscale für sicheren Fernzugriff eingerichtet
- Keine Portfreigaben im Router erforderlich

---

# Aktuelle Infrastruktur

Nach Abschluss des Raspberry-Pi-Setups läuft folgende Infrastruktur auf dem Host:

- Docker Engine
- Docker Compose
- Docker-Netzwerk `atlas-network`
- Traefik
- PostgreSQL
- n8n

Die gesamte Infrastruktur wird containerisiert betrieben und kommuniziert über das gemeinsame Docker-Netzwerk.

---

# Nächster Ausbauschritt

Die Grundinstallation des Hostsystems ist abgeschlossen.

Die weitere Entwicklung konzentriert sich auf den Ausbau der Atlas-Infrastruktur, beispielsweise durch:

- Redis
- Monitoring
- Backup-Strategie
- Weitere Infrastruktur-Dienste
- Überführung der Infrastruktur in ein versioniertes Git-Repository (Infrastructure as Code)
