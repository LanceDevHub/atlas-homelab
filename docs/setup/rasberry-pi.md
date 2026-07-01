# Atlas HomeLab -- Setup Dokumentation

> Erstes Setup des Raspberry Pi 5 als HomeLab.

## Aktueller Stand

-   Raspberry Pi OS installiert
-   Headless-Betrieb eingerichtet
-   SSH eingerichtet
-   Tailscale eingerichtet
-   SSH-Schlüssel eingerichtet
-   Passwort-Authentifizierung deaktiviert
-   UFW aktiviert

------------------------------------------------------------------------

## 1. System aktualisieren

``` bash
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo reboot
```

## 2. Headless-Modus

``` bash
systemctl get-default
sudo systemctl set-default multi-user.target
sudo reboot
```

Optional:

``` bash
sudo systemctl isolate multi-user.target
```

## 3. Hostname ändern

``` bash
sudo hostnamectl set-hostname atlas
sudo nano /etc/hosts
sudo reboot
hostname
```

`/etc/hosts`:

``` text
127.0.1.1 atlas
```

## 4. SSH

``` bash
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh
hostname -I
```

## 5. Tailscale

``` bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
tailscale status
ip addr show tailscale0
```

## 6. SSH-Schlüssel

Windows:

``` powershell
ls ~/.ssh
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh lenny@atlas "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

Pi:

``` bash
ls -la ~/.ssh
cat ~/.ssh/authorized_keys
```

## 7. SSH absichern

Datei:

``` bash
sudo nano /etc/ssh/sshd_config.d/99-hardening.conf
```

Inhalt:

``` text
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin no
```

Prüfen:

``` bash
sudo sshd -t
sudo systemctl restart ssh
sudo sshd -T | grep -E 'passwordauthentication|pubkeyauthentication|permitrootlogin'
```

## 8. UFW

``` bash
sudo apt install ufw -y
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status verbose
```

## Erreichte Sicherheitsziele

-   SSH nur per Public Key
-   Root-Login deaktiviert
-   UFW aktiv
-   Tailscale eingerichtet
-   Fernzugriff ohne Portfreigabe

## Nächste Schritte

-   [ ] Git
-   [ ] Docker
-   [ ] Docker Compose
-   [ ] HomeLab-Struktur
-   [ ] Git-Repository
-   [ ] n8n
-   [ ] PostgreSQL
-   [ ] Automatisierungen
