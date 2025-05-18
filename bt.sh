
echo "Resetting UFW and setting default policies..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing


echo "Blocking torrent ports..."
# Common torrent ports
sudo ufw deny out 6881:6889/tcp
sudo ufw deny out 6881:6889/udp
sudo ufw deny out 6969/tcp
sudo ufw deny out 51413
sudo ufw deny out 1337/tcp
sudo ufw deny out 2710/tcp
sudo ufw deny out 8999/tcp
sudo ufw deny out 8999/udp
sudo ufw deny out 42069/tcp
sudo ufw deny out 42069/udp
sudo ufw deny out 16881/tcp
sudo ufw deny out 16881/udp
sudo ufw deny out 6880:6999/tcp
sudo ufw deny out 6880:6999/udp

echo "Enabling UFW and turning on logging..."
sudo ufw logging on
sudo ufw --force enable
sudo ufw status numbered
