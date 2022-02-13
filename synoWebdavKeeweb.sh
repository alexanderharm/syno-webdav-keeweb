#!/bin/bash

# check if run as root
if [ $(id -u "$(whoami)") -ne 0 ]; then
	echo "SynoWebdavKeeweb needs to run as root!"
	exit 1
fi

# check if git is available
if command -v /usr/bin/git > /dev/null; then
	git="/usr/bin/git"
elif command -v /usr/local/git/bin/git > /dev/null; then
	git="/usr/local/git/bin/git"
elif command -v /opt/bin/git > /dev/null; then
	git="/opt/bin/git"
else
	echo "Git not found therefore no autoupdate. Please install the official package \"Git Server\", SynoCommunity's \"git\" or Entware-ng's."
	git=""
fi

# check if WebDAV Server is installed
if [ ! -d "/var/packages/WebDAVServer" ]; then
	echo "WebDAV Server not installed! Please install the official package."
	exit 1
fi

# save today's date
today=$(date +'%Y-%m-%d')

# self update run once daily
if [ ! -z "${git}" ] && [ -d "$(dirname "$0")/.git" ] && [ -f "$(dirname "$0")/autoupdate" ]; then
	if [ ! -f /tmp/.synoWebdavKeewebUpdate ] || [ "${today}" != "$(date -r /tmp/.synoWebdavKeewebUpdate +'%Y-%m-%d')" ]; then
		echo "Checking for updates..."
		# touch file to indicate update has run once
		touch /tmp/.synoWebdavKeewebUpdate
		# change dir and update via git
		cd "$(dirname "$0")" || exit 1
		git fetch
		commits=$(git rev-list HEAD...origin/master --count)
		if [ $commits -gt 0 ]; then
			echo "Found a new version, updating..."
			git pull --force
			echo "Executing new version..."
			exec "$(pwd -P)/synoWebdavKeeweb.sh" "$@"
			# In case executing new fails
			echo "Executing new version failed."
			exit 1
		fi
		echo "No updates available."
	else
		echo "Already checked for updates today."
	fi
fi

# Save if service restart is needed
serviceRestart=0

# Check if module mod_rewrite.so is loaded
if ! grep -q '# Added to enable CORS and KeeWeb compatibility' "/var/packages/WebDAVServer/target/etc/httpd/conf/httpd.conf-webdav"; then
	sed -i 's:^User root$:# Added to enable CORS and KeeWeb compatibility\n\n&:' "/var/packages/WebDAVServer/target/etc/httpd/conf/httpd.conf-webdav"
	((serviceRestart++))
fi
if ! grep -q 'LoadModule rewrite_module modules/mod_rewrite.so' "/var/packages/WebDAVServer/target/etc/httpd/conf/httpd.conf-webdav"; then
	sed -i 's:# Added to enable CORS and KeeWeb compatibility:&\nLoadModule rewrite_module modules/mod_rewrite.so:' "/var/packages/WebDAVServer/target/etc/httpd/conf/httpd.conf-webdav"
	((serviceRestart++))
fi

# Check if headers are set
if ! grep -q '# Added to enable CORS and KeeWeb compatibility' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"; then
	sed -i 's|^    SSLEngine on$|&\n\n    # Added to enable CORS and KeeWeb compatibility|' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"
	((serviceRestart++))
fi
if ! grep -q 'Header always set Access-Control-Allow-Origin "*"' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"; then
	sed -i 's|    # Added to enable CORS and KeeWeb compatibility|&\n    Header always set Access-Control-Allow-Origin "*"|' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"
	((serviceRestart++))
fi
if ! grep -q 'Header always set Access-Control-Allow-Headers "origin, content-type, cache-control, accept, authorization, if-match, destination, overwrite, depth"' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"; then
	sed -i 's|    Header always set Access-Control-Allow-Origin "\*"|&\n    Header always set Access-Control-Allow-Headers "origin, content-type, cache-control, accept, authorization, if-match, destination, overwrite, depth"|' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"
	((serviceRestart++))
fi
if ! grep -q 'Header always set Access-Control-Expose-Headers "ETag"' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"; then
	sed -i 's|    Header always set Access-Control-Allow-Headers "origin, content-type, cache-control, accept, authorization, if-match, destination, overwrite, depth"|&\n    Header always set Access-Control-Expose-Headers "ETag"|' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"
	((serviceRestart++))
fi
if ! grep -q 'Header always set Access-Control-Allow-Methods "GET, HEAD, POST, PUT, OPTIONS, MOVE, DELETE, COPY, LOCK, UNLOCK"' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"; then
	sed -i 's|    Header always set Access-Control-Expose-Headers "ETag"|&\n    Header always set Access-Control-Allow-Methods "GET, HEAD, POST, PUT, OPTIONS, MOVE, DELETE, COPY, LOCK, UNLOCK"|' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"
	((serviceRestart++))
fi
if ! grep -q 'Header always set Access-Control-Allow-Credentials "true"' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"; then
	sed -i 's|    Header always set Access-Control-Allow-Methods "GET, HEAD, POST, PUT, OPTIONS, MOVE, DELETE, COPY, LOCK, UNLOCK"|&\n    Header always set Access-Control-Allow-Credentials "true"|' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"
	((serviceRestart++))
fi

# Check if rewrite rules are set
if ! grep -q 'RewriteEngine on' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"; then
	sed -i 's|    Header always set Access-Control-Allow-Credentials "true"|&\n    RewriteEngine on|' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"
	((serviceRestart++))
fi
if ! grep -q 'RewriteCond %{REQUEST_METHOD} OPTIONS' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"; then
	sed -i 's|    RewriteEngine on|&\n    RewriteCond %{REQUEST_METHOD} OPTIONS|' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"
	((serviceRestart++))
fi
if ! grep -q 'RewriteRule ^(.\*)$ blank.html \[R=200,L,E=HTTP_ORIGIN:%{HTTP:ORIGIN}\]' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"; then
	sed -i 's|    RewriteCond %{REQUEST_METHOD} OPTIONS|&\n    RewriteRule ^(.*)$ blank.html [R=200,L,E=HTTP_ORIGIN:%{HTTP:ORIGIN}]|' "/var/packages/WebDAVServer/target/etc/httpd/conf/extra/httpd-ssl.conf-webdav"
	((serviceRestart++))
fi

# Restart service if needed
if [ $serviceRestart -gt 0 ]; then
	echo "Config modified. Restarting WebDAV service..."
	if [ -x /usr/syno/sbin/synoservice  ]; then
	    synoservice --restart pkgctl-WebDAVServer
	elif [ -x /bin/systemctl  ]; then
	    systemctl restart pkgctl-WebDAVServer.service
	else
		echo "Could not restart WebDAV service! Please reboot or try to restart manually via Package Center."
		exit 1
	fi
	echo "WebDAV service restarted."
else
	echo "Config untouched."
fi
exit 0
