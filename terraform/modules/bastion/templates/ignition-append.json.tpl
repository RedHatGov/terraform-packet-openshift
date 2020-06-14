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
            "path": "/etc/hosts",
            "mode": 644,
            "overwrite": true,
            "contents": {
               "source": "data:,127.0.0.1%20%20%20localhost%20localhost.localdomain%20localhost4%20localhost4.localdomain4%0A%3A%3A1%20%20%20%20%20%20%20%20%20localhost%20localhost.localdomain%20localhost6%20localhost6.localdomain6%0A%0A${bastion_ip}%20%20%20api.${cluster_name}.${cluster_basedomain}%0A${bastion_ip}%20%20%20api-int.${cluster_name}.${cluster_basedomain}%0A%0A"
            }
         }
      ]
   },
  "networkd": {},
  "passwd": {},
  "systemd": {}
}