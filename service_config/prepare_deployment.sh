#!/bin/bash

# replace secrets
if [ -z "$SPRING_BOOT_ADMIN_USER" ]; then
  echo "SPRING_BOOT_ADMIN_USER is not set. Check your secrets."
  exit 2
else
  sed -i "s/SPRING_BOOT_ADMIN_USER/$SPRING_BOOT_ADMIN_USER/g" ./service_config/files/qb-kgqanwrapper-dbpedia
  sed -i "s/SPRING_BOOT_ADMIN_USER/$SPRING_BOOT_ADMIN_USER/g" ./service_config/files/qb-kgqanwrapper-wikidata
fi

if [ -z "$SPRING_BOOT_ADMIN_PASSWORD" ]; then
  echo "SPRING_BOOT_ADMIN_PASSWORD is not set. Check your secrets."
  exit 2
else
  sed -i "s/SPRING_BOOT_ADMIN_PASSWORD/$SPRING_BOOT_ADMIN_PASSWORD/g" ./service_config/files/qb-kgqanwrapper-dbpedia
  sed -i "s/SPRING_BOOT_ADMIN_PASSWORD/$SPRING_BOOT_ADMIN_PASSWORD/g" ./service_config/files/qb-kgqanwrapper-wikidata
fi
