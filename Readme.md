# Dockerized Pure-ftpd-MySQL
Pure-ftpd with MySQL, TLS, Passive mode and upload script option

# Docker command
```bash
docker run -d \
  --network=host \
  -e PUBLIC_IP="127.0.0.1" \
  -e PORT_RANGE="30000:30007" \
  -v /home/dyedfox/ssl:/etc/ssl/private \
  -v /home/dyedfox/ftpdata:/home/ftpdata \
  -v /home/dyedfox/ftpdata/uploadscript.sh:/etc/uploadscript.sh \
  -v /home/dyedfox/ftpdata/mysql.conf:/etc/pure-ftpd/db/mysql.conf \
  --restart always \
  --log-driver syslog \
  --name pure-ftpd-mysql \
  pure-ftpd-mysql:latest
  ```

# Docker compose
See `docker-compose.yaml`

## Parameters
  `--network=host` - if omitted, you need to map ports for passive mode like this: `-p 30000-31000:30000-31000`. Can be slow in non-host mode if the port range is large

  `-e PUBLIC_IP="127.0.0.1"` - public IP for passive mode

  `-e PORT_RANGE="30000:30007` - port range for passive mode

  `-v /home/dyedfox/ssl:/etc/ssl/private` - left side is path to your certificate

  `-v /home/dyedfox/ftpdata:/home/ftpdata` - path to host volume for storing the uploaded files

  `-v /home/dyedfox/ftpdata/uploadscript.sh:/etc/uploadscript.sh` - path to the uploadscript

  `-v /home/dyedfox/ftpdata/mysql.conf:/etc/pure-ftpd/db/mysql.conf` - path to MySQL configuration file

  `--restart always` - always restart the containder

  `--log-driver syslog` - mapping logging to the host system
  
  `--name pure-ftpd-mysql` - name of the container


# The workflow examples
## Create users

User 1
```sql
INSERT INTO `users` (`User`, `Password`, `Uid`, `Gid`, `Dir`)
VALUES ('ftpuser1', 'zara2stra2107', '1004', '1004', '/home/ftpdata/ftpuser1');
```
User 2
```sql
INSERT INTO `users` (`User`, `Password`, `Uid`, `Gid`, `Dir`)
VALUES ('ftpuser2', 'zara2stra2107', '1004', '1004', '/home/ftpdata/ftpuser2');
```

### Note
In mysql.conf > MYSQLDefaultUID 1001 parameter, the default uid:gid for uploaded files is set.
Therefore, if 1000 is the hosts system user, the directories ftpuser1, ftpuser2 would have 1001:1001 uid:gid attributes.

```bash
cd /home/
ls -lah
total 12K
drwxr-xr-x 1 root root 4.0K Aug 10 09:00 .
drwxr-xr-x 1 root root 4.0K Aug 10 09:00 ..
drwxrwxr-x 4 1000 1000 4.0K Aug 10 11:50 ftpdata
cd ftpdata/
ls -lah
total 24K
drwxrwxr-x 4 1000 1000 4.0K Aug 10 11:50 .
drwxr-xr-x 1 root root 4.0K Aug 10 09:00 ..
drwxr-xr-x 2 1001 1001 4.0K Aug 10 11:53 ftpuser1
drwxr-xr-x 2 1001 1001 4.0K Aug 10 09:00 ftpuser2
-rw-rw-r-- 1 1000 1000  431 Aug 10 11:50 mysql.conf
-rw-rw-r-- 1 1000 1000   61 Aug 10 08:47 uploadscript.sh
```

## Delete user
```sql
DELETE FROM `users`
WHERE `User` = 'ftpuser1'
  AND `Password` = 'zara2stra2107'
  AND `Uid` = '1004'
  AND `Gid` = '1004'
  AND `Dir` = '/home/ftpdata/ftpuser1';
```

## Update user
```sql
UPDATE users
SET Password = 'zara2stra2107',
    Uid = 1000,
    Gid = 1000,
    Dir = '/home/ftpdata/ftpuser1'
WHERE User = 'ftpuser';
```

```bash
UPDATE users
SET Password = 'zara2stra2107',
    Uid = 1000,
    Gid = 1000,
    Dir = '/home/ftpdata/ftpuser1'
WHERE User = 'ftpuser1';
```