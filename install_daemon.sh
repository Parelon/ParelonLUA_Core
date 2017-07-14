#!/bin/bash

echo "Installing the daemon..."
cp parelon /etc/init.d/

echo "Set permissions..."
chmod +x /etc/init.d/parelon

echo "Making PID directory..."
mkdir /var/run/parelon

echo "Set PID directory permissions..."
chown www-data:www-data /var/run/parelon

echo "Setting the daemon start at system start"
update-rc.d parelon defaults

echo "Done"

exit 0
