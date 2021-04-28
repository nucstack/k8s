#!/bin/sh

echo "Starting rtl_tcp..."
rtl_tcp &

sleep 30

while true; do
  rtlamr | rtlamr-collect
  sleep ${INTERVAL}
done