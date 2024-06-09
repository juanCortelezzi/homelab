#!/bin/bash

# gets the KOKAN_FORWARDER environment variable which should
# hold an ip or domain name (including docker containers) 
# to set as the forwarder ip for bind9.

PATH_TO_TEMPLATES="$1"
PATH_TO_CONFIG="$2"

# if PATH_TO_TEMPLATES is empty, exit
if [ -z "$PATH_TO_TEMPLATES" ]; then
  echo "Please provide a path to the templates folder."
  exit 1
fi

# if PATH_TO_CONFIG is empty, exit
if [ -z "$PATH_TO_CONFIG" ]; then
  echo "Please provide a path to the config folder."
  exit 1
fi

KEY="// kokan::FORWARDER"
VALUE=$(env | grep -e "^KOKAN_FORWARDER=" | cut -d "=" -f 2)

# if VALUE is empty, exit
if [ -z "$VALUE" ]; then
  echo "Please provide a value for KOKAN_FORWARDER."
  exit 1
fi

CONTAINER_IP=$(dig +short "$VALUE" | head -n 1)

# if CONTAINER_IP is empty, exit
if [ -z "$CONTAINER_IP" ]; then
  echo "Could not resolve '$VALUE' to an IP address. Exiting."
  exit 1
fi

cp -r "$PATH_TO_TEMPLATES"/* "$PATH_TO_CONFIG"

FILES_WITH_REPLACER=$(grep -rl "$KEY" "$PATH_TO_CONFIG")

# if FILES_WITH_REPLACER is empty, exit
if [ -z "$FILES_WITH_REPLACER" ]; then
  echo "No files found with the replacer key '$KEY'. Exiting."
  exit 1
fi

for FILE in $FILES_WITH_REPLACER; do
  echo "Replacing: '$KEY' with '$CONTAINER_IP' in '$FILE'"
  sed -i "s|$KEY$|$CONTAINER_IP;|g" "$FILE"
done
