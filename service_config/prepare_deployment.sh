#!/bin/bash

# replace secrets
if [ -z "$SPRING_BOOT_ADMIN_USERNAME" ]; then
  echo "SPRING_BOOT_ADMIN_USERNAME is not set. Check your secrets."
  exit 2
else
  sed -i "s/SPRING_BOOT_ADMIN_USERNAME_PLACEHOLDER/$SPRING_BOOT_ADMIN_USERNAME/g" ./service_config/files/qb-kgqanwrapper-dbpedia
  sed -i "s/SPRING_BOOT_ADMIN_USERNAME_PLACEHOLDER/$SPRING_BOOT_ADMIN_USERNAME/g" ./service_config/files/qb-kgqanwrapper-wikidata
fi

if [ -z "$SPRING_BOOT_ADMIN_PASSWORD" ]; then
  echo "SPRING_BOOT_ADMIN_PASSWORD is not set. Check your secrets."
  exit 2
else
  sed -i "s/SPRING_BOOT_ADMIN_PASSWORD_PLACEHOLDER/$SPRING_BOOT_ADMIN_PASSWORD/g" ./service_config/files/qb-kgqanwrapper-dbpedia
  sed -i "s/SPRING_BOOT_ADMIN_PASSWORD_PLACEHOLDER/$SPRING_BOOT_ADMIN_PASSWORD/g" ./service_config/files/qb-kgqanwrapper-wikidata
fi
