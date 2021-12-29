#!/bin/bash
cat /etc/hosts
sudo echo "127.0.0.1    eprints.id" >> /etc/hosts
cat /etc/hosts
service mysql start
service apache2 start
tail -f /var/log/apache2/*.log
