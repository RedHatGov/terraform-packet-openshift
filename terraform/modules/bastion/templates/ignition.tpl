{
  "ignition": {
    "config": {
      "append": [
        {
          "source": "http://${ bastion_ip }:8080/${ node_type }.ign",
          "verification": {}
        }
      ]
    },
    "security": {},
    "timeouts": {},
    "version": "2.2.0"
  },
  "networkd": {
      "units": [
          {
              "contents": "[Match]\nName=en*\n\n[Network]\nDHCP=yes\nDNS=1.1.1.1\nDNS=8.8.8.8",
              "name": "00-en-dhcp-dns.network"
          }
      ]
  },
  "passwd": {},
  "storage": {},
  "systemd": {}
}