#!/usr/bin/env bash

set -e

args=()

[ -n "$OPENCODE_SERVER_HOSTNAME" ] && args+=(--hostname "$OPENCODE_SERVER_HOSTNAME")
[ -n "$OPENCODE_SERVER_PORT" ] && args+=(--port "$OPENCODE_SERVER_PORT")

if [ "$OPENCODE_SERVER_MDNS" = "true" ]; then
  args+=(--mdns)
fi

if [ -n "$OPENCODE_SERVER_CORS" ] && [ "$OPENCODE_SERVER_CORS" != "[]" ]; then
  cors=$(echo "$OPENCODE_SERVER_CORS" | tr -d '[]"' | tr ',' ' ')
  for c in $cors; do
    args+=(--cors "$c")
  done
fi

echo "${args[@]}"

exec opencode web "${args[@]}" "$@"
