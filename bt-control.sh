#!/bin/bash

echo "[+] Installing 'bt' command to control torrent blocking..."

cat << 'EOF' > /usr/local/bin/bt
#!/bin/bash
case "\$1" in
  on)
    echo "[+] Enabling torrent blocking rules..."
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t mangle -F
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

    iptables -A OUTPUT -p tcp --dport 6881:6999 -j DROP
    iptables -A OUTPUT -p udp --dport 6881:6999 -j DROP
    iptables -A INPUT  -p tcp --dport 6881:6999 -j DROP
    iptables -A INPUT  -p udp --dport 6881:6999 -j DROP

    iptables -A OUTPUT -p tcp --dport 51413 -j DROP
    iptables -A OUTPUT -p udp --dport 51413 -j DROP
    iptables -A INPUT  -p tcp --dport 51413 -j DROP
    iptables -A INPUT  -p udp --dport 51413 -j DROP

    for keyword in "BitTorrent" "BitTorrent protocol" "peer_id=" ".torrent" "announce" "info_hash" "tracker" "get_peers" "find_node" "announce_peer" "BitComet" "uTorrent" "magnet:"; do
        iptables -A FORWARD -m string --string "\$keyword" --algo bm -j DROP
        iptables -A OUTPUT  -m string --string "\$keyword" --algo bm -j DROP
        iptables -A INPUT   -m string --string "\$keyword" --algo bm -j DROP
    done

    iptables -A FORWARD -p udp --dport 6881:6999 -j DROP
    iptables -A OUTPUT  -p udp --dport 6881:6999 -j DROP
    iptables -A INPUT   -p udp --dport 6881:6999 -j DROP

    iptables -A OUTPUT -p udp --dport 33434:65535 -m conntrack --ctstate NEW -j DROP

    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6
    systemctl restart netfilter-persistent
    echo "[✓] Torrent blocking enabled."
    ;;
  off)
    echo "[+] Disabling torrent blocking rules..."
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t mangle -F
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6
    systemctl restart netfilter-persistent
    echo "[✓] Torrent blocking disabled."
    ;;
  *)
    echo "Usage: bt {on|off}"
    ;;
esac
EOF

chmod +x /usr/local/bin/bt
echo "[✓] Installed. You can now run 'bt on' or 'bt off'"
