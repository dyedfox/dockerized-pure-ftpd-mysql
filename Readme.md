# Dockerized Pure-ftpd-MySQL
The project provides a Docker container for Pure-ftpd with MySQL support, TLS, Passive mode, and upload script options.

For detailed Pure-ftpd documentation, refer to:
- https://linux.die.net/man/8/pure-ftpd
- https://www.pureftpd.org/project/pure-ftpd/doc/

# Docker hub link
https://hub.docker.com/repository/docker/slavko7/pure-ftpd-mysql/general

## Docker Command

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
  slavko7/pure-ftpd-mysql:latest
```

## Docker Compose

See `docker-compose.yaml`.

## Parameters

- `--network=host`: Use host network. If omitted, you need to map ports for passive mode (e.g., `-p 30000-31000:30000-31000`). Note that non-host mode can be slow if the port range is large.
- `-e PUBLIC_IP="127.0.0.1"`: Public IP for passive mode.
- `-e PORT_RANGE="30000:30007"`: Port range for passive mode.
- `-e RUN_ARGS="-o -Y 2 -A -J HIGH -E -j"`: Arguments for pure-ftpd-mysql service (default shown). Refer to https://linux.die.net/man/8/pure-ftpd for more options.
- `-v /home/dyedfox/ssl:/etc/ssl/private`: Path to your SSL certificate.
- `-v /home/dyedfox/ftpdata:/home/ftpdata`: Host volume path for storing uploaded files.
- `-v /home/dyedfox/ftpdata/uploadscript.sh:/etc/uploadscript.sh`: Path to the upload script. For more info, see: https://linux.die.net/man/8/pure-uploadscript
- `-v /home/dyedfox/ftpdata/mysql.conf:/etc/pure-ftpd/db/mysql.conf`: Path to MySQL configuration file.
- `--restart always`: Always restart the container.
- `--log-driver syslog`: Map logging to the host system.
- `--name pure-ftpd-mysql`: Name of the container.

## Workflow Examples

### Create Users

User 1:
```sql
INSERT INTO `users` (`User`, `Password`, `Uid`, `Gid`, `Dir`)
VALUES ('ftpuser1', 'sUperSecretP4as$word', '1004', '1004', '/home/ftpdata/ftpuser1');
```

User 2:
```sql
INSERT INTO `users` (`User`, `Password`, `Uid`, `Gid`, `Dir`)
VALUES ('ftpuser2', 'sUperSecretP4as$word', '1004', '1004', '/home/ftpdata/ftpuser2');
```

### Note on User Permissions

In `mysql.conf`, the `MYSQLDefaultUID` parameter is set to 1001, which defines the default uid:gid for uploaded files. If 1000 is the host system user, the directories `ftpuser1` and `ftpuser2` would have 1001:1001 uid:gid attributes.

Example directory structure:
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
-rw-rw-r-- 1 1000 1000 431 Aug 10 11:50 mysql.conf
-rw-rw-r-- 1 1000 1000 61 Aug 10 08:47 uploadscript.sh
```

### Delete User

```sql
DELETE FROM `users`
WHERE `User` = 'ftpuser1'
  AND `Password` = 'sUperSecretP4as$word'
  AND `Uid` = '1004'
  AND `Gid` = '1004'
  AND `Dir` = '/home/ftpdata/ftpuser1';
```

### Update User

```sql
UPDATE users
SET Password = 'sUperSecretP4as$word',
    Uid = 1000,
    Gid = 1000,
    Dir = '/home/ftpdata/ftpuser1'
WHERE User = 'ftpuser1';
```