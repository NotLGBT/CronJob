#!/bin/bash

SERVICE_NAME="arp-daemon"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
DAEMON_SCRIPT="/usr/local/bin/arp_daemon.sh"
LOG_FILE="/var/log/arp_cache.log"

sudo touch "${LOG_FILE}"
sudo chmod 644 "${LOG_FILE}"

if [ ! -f "${DAEMON_SCRIPT}" ]; then
    cat << EOF > "${DAEMON_SCRIPT}"
#!/bin/bash

LOG_FILE="${LOG_FILE}"

print_arp_cache() {
    if command -v arp > /dev/null 2>&1; then
        echo "Iface                HWaddress"
        echo "-----------------------------------------"
        arp -a | awk '{printf "%-20s %-20s\n", \$7, \$4}'
    elif ip -4 neigh show dev eth0 > /dev/null 2>&1; then
        echo "ARP cache for interface eth0:"
        ip -4 neigh show dev eth0
        echo "-------------------------"
    else
        echo "Unable to find specific interface or ARP command."
    fi
}

while true; do
    print_arp_cache >> "\${LOG_FILE}"
    sleep 60  # Pause for 60 seconds
done
EOF

    chmod +x "${DAEMON_SCRIPT}"
    echo "Daemon script created at ${DAEMON_SCRIPT}"
else
    echo "Daemon script already exists at ${DAEMON_SCRIPT}"
fi

cat << EOF > "${SERVICE_FILE}"
[Unit]
Description=ARP Cache Daemon
After=network.target

[Service]
Type=simple
ExecStart=${DAEMON_SCRIPT}
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start "${SERVICE_NAME}.service"
systemctl enable "${SERVICE_NAME}.service"

echo "Service ${SERVICE_NAME} created and started."

sudo chmod +x "${DAEMON_SCRIPT}"
