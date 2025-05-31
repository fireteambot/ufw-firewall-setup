#!/bin/bash

# Download scripts from GitHub
wget -O /usr/local/bin/bt-on.sh https://raw.githubusercontent.com/fireteambot/ufw-firewall-setup/main/bt-on.sh
wget -O /usr/local/bin/bt-off.sh https://raw.githubusercontent.com/fireteambot/ufw-firewall-setup/main/bt-off.sh
wget -O /usr/local/bin/bt https://raw.githubusercontent.com/fireteambot/ufw-firewall-setup/main/bt

# Make them executable
chmod +x /usr/local/bin/bt*
echo "[✓] Installed bt toggle command. Use: bt on | bt off"
