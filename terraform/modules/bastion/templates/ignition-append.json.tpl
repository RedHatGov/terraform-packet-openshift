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
   "storage": {
      "files": [
         {
            "filesystem": "root",
            "path": "/etc/dhcp/dhclient.conf",
            "mode": 644,
            "overwrite": true,
            "contents": {
               "source": "data:text/plain;charset=utf-8,send%20dhcp-client-identifier%20%3D%20hardware%3B%0D%0Aprepend%20domain-name-servers%201.1.1.1%3B"
            }
         }
      ]
   },
  "networkd": {},
  "passwd": {},
  "systemd": {}
}