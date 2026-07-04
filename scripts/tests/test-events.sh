#!/usr/bin/env bash

set -Eeuo pipefail

source "../lib/events.sh"

payload=$(
    event_payload \
        --arg directory "2026-07-04_03-00-00" \
        '{
            directory: $directory
        }'
)



event_emit \
    "atlas-backup" \
    "backup.completed" \
    "success" \
    "${payload}"

echo "Event created successfully."