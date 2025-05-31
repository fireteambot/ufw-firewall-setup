#!/bin/bash

echo "[+] Installing iptables-persistent..."
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent

echo "[+] Resetting iptables rules..."
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

echo "[+] Blocking torrent keywords via string match..."
for keyword in "BitTorrent" "BitTorrent protocol" "peer_id=" ".torrent" "announce" "info_hash" "tracker" "get_peers" "find_node" "announce_peer" "BitComet" "uTorrent"; do
    sudo iptables -A FORWARD -m string --string "$keyword" --algo bm -j DROP
    sudo iptables -A OUTPUT  -m string --string "$keyword" --algo bm -j DROP
    sudo iptables -A INPUT   -m string --string "$keyword" --algo bm -j DROP
done

echo "[+] Blocking common torrent ports..."
for port in 6881 6882 6883 6884 6885 6886 6887 6888 6889 6969 51413 1337 2710 8999 42069 16881; do
    sudo iptables -A INPUT -p tcp --dport $port -j DROP
    sudo iptables -A INPUT -p udp --dport $port -j DROP
    sudo iptables -A OUTPUT -p tcp --dport $port -j DROP
    sudo iptables -A OUTPUT -p udp --dport $port -j DROP
done

echo "[+] Blocking torrent port ranges..."
sudo iptables -A OUTPUT -p tcp --dport 6880:6999 -j DROP
sudo iptables -A OUTPUT -p udp --dport 6880:6999 -j DROP
sudo iptables -A INPUT  -p tcp --dport 6880:6999 -j DROP
sudo iptables -A INPUT  -p udp --dport 6880:6999 -j DROP

echo "[+] Saving iptables rules..."
sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null
sudo ip6tables-save | sudo tee /etc/iptables/rules.v6 > /dev/null

echo "[+] Restarting iptables-persistent..."
sudo systemctl restart netfilter-persistent

echo "[✓] Torrent traffic blocking configured and saved."
