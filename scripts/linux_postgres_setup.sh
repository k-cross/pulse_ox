#!/bin/sh

echo "Setup postgres"

user_name=pulseox
password=pulseoximeter
echo "CREATE ROLE $user_name WITH LOGIN PASSWORD '$password';" | sudo -i -u postgres psql
sudo -i -u postgres createdb --owner=$user_name pulse_ox_dev
sudo -i -u postgres createdb --owner=$user_name pulse_ox_test
sudo -i -u postgres createdb --owner=$user_name pulse_ox

echo "Setup complete"

