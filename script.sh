
if command -v arp > /dev/null 2>&1; then
    echo "Iface                HWaddress"
    echo "-----------------------------------------"
    arp -a | awk '{printf "%-20s %-20s\n", $7, $4}'
elif ip -4 neigh show dev eth0 > /dev/null 2>&1; then
    echo "ARP cache for interface eth0:"
    ip -4 neigh show dev eth0
    echo "-------------------------"
else
    echo "Unable to find specific interface or ARP command."
fi
