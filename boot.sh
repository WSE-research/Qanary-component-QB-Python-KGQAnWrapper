#!/bin/sh

export $(grep -v '^#' .env | xargs)

echo The port number is: $SERVER_PORT
echo The host is: $SERVER_HOST
echo The Qanary pipeline URL is: $SPRING_BOOT_ADMIN_URL
if [ -n $SERVER_PORT ]
then
    exec uvicorn run:app --host 0.0.0.0 --port $SERVER_PORT
fi
