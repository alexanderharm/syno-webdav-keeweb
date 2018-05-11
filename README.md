# Syno WebDAV KeeWeb

This script enables CORS in Synology's WebDAV Server package (<https://www.synology.com/en-global/dsm/packages/WebDAVServer>). This is necessary for hosting KeePass (<https://keepass.info/>) files that you want to use with KeeWeb (<https://keeweb.info/>).

All credits go to Vincent Lamouroux (@skad). You can find his original posting here <https://github.com/keeweb/keeweb/issues/703#issuecomment-326404286>.

#### 1. Notes

- KeeWeb doesn't like self-signed certificates when using HTTPS.
- The script will automatically update itself using `git`.

#### 2. Installation

##### 2.1 Install WebDAV

- Install the package `WebDAV Server` using the `Package Center` in the WebGUI

##### 2.2 Install Git

- install the package `Git Server` on your Synology NAS, make sure it is running (requires sometimes extra action in `Package Center` and `SSH` running)
- alternatively add SynoCommunity to `Package Center` and install the `Git` package ([https://synocommunity.com/](https://synocommunity.com/#easy-install))
- you can also use `entware-ng` (<https://github.com/Entware/Entware-ng>)

##### 2.3 Install this script

- create a shared folder e. g. `sysadmin` (you want to restrict access to administrators and hide it in the network)
- connect via `ssh` to the NAS and execute the following commands

```bash
# navigate to the shared folder
cd /volume1/sysadmin
# clone the following repo
git clone https://github.com/alexanderharm/syno-webdav-keeweb
```

#### 3. Setup

- configure the `WebDAV Server`, e. g. enable HTTPS and set a non-standard port

- create a task in the `Task Scheduler` via WebGUI

```
# Type
Scheduled task > User-defined script

# General
Task:    SynoWebdavKeepass
User:    root
Enabled: yes

# Schedule
Run on the following days: Daily
First run time:            00:00
Frequency:                 Every 1 hour(s)
Last run time:			   23:00

# Task Settings
User-defined script: /volume1/sysadmin/syno-webdav-keeweb/synoWebdavKeeweb.sh"
```
