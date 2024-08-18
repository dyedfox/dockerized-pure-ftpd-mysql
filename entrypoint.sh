#!/bin/bash

cp /etc/uploadscript.sh /etc/uploadscript-exe.sh
chmod +x /etc/uploadscript-exe.sh

service syslog-ng start

# RUN_ARGS={"-o -Y 2 -A -J HIGH -E -j"}
/usr/sbin/pure-uploadscript -B -r /etc/uploadscript-exe.sh
/usr/sbin/pure-ftpd-mysql -l mysql:/etc/pure-ftpd/db/mysql.conf -B -u 1000 ${RUN_ARGS} -P ${PUBLIC_IP} -p ${PORT_RANGE} -O clf:/var/log/pure-ftpd/transfer.log && tail -f /var/log/syslog
