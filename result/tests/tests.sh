#!/bin/sh

while ! timeout 1 bash -c "echo > /dev/tcp/vote/8080"; do
    sleep 1
done

curl -sS -X POST --data "vote=b" http://vote:8080 > /dev/null

# Poll for up to ~60 seconds instead of one fixed sleep
for i in $(seq 1 30); do
  if phantomjs render.js http://result:8080 | grep -q '1 vote'; then
    echo -e "\\e[42m------------"
    echo -e "\\e[92mTests passed"
    echo -e "\\e[42m------------"
    exit 0
  fi
  sleep 2
done

echo -e "\\e[41m------------"
echo -e "\\e[91mTests failed"
echo -e "\\e[41m------------"
exit 1