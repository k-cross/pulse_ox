#!/bin/sh

echo "Setup postgres"

user_name=pulseox
password=pulseoximeter
echo "CREATE ROLE $user_name WITH LOGIN PASSWORD '$password';" | psql
createdb --owner=$user_name pulse_ox_dev
createdb --owner=$user_name pulse_ox_test
createdb --owner=$user_name pulse_ox

echo "Setup complete"

