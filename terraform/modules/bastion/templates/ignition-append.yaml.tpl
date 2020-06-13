ignition:
  config:
    append:
      - source: "http://${ bastion_ip }:8080/${ node_type }.ign"
storage:
  files:
    - filesystem: root
      path: /etc/dhcp/dhclient.conf
      mode: 644
      contents:
        inline: |
          send dhcp-client-identifier = hardware;
          supersede domain-name-servers 1.1.1.1;
          supersede domain-name-servers 8.8.8.8;