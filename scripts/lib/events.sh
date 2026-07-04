# ==================================================
# Configuration
# ==================================================

readonly EVENTS_DIR="/opt/atlas/events"

# ==================================================
# Internal functions
# ==================================================

create_events_directory() {

    mkdir -p "${EVENTS_DIR}"

}

create_timestamp() {

    date -u +"%Y-%m-%dT%H:%M:%SZ"

}

create_event_id() {

    date -u +"%Y%m%dT%H%M%S%N"

}

create_filename() {

    local event_id="${1}"
    local source="${2}"
    local event="${3}"

    printf "%s-%s-%s.json\n" \
        "${event_id}" \
        "${source}" \
        "${event}"

}

write_event() {

    local filename="${1}"
    local event_id="${2}"
    local event="${3}"
    local timestamp="${4}"
    local source="${5}"
    local status="${6}"
    local payload="${7}"

    if ! jq \
        -n \
        --arg id "${event_id}" \
        --arg event "${event}" \
        --arg timestamp "${timestamp}" \
        --arg source "${source}" \
        --arg status "${status}" \
        --argjson payload "${payload}" \
        '{
            id: $id,
            event: $event,
            timestamp: $timestamp,
            source: $source,
            status: $status,
            payload: $payload
        }' \
        > "${EVENTS_DIR}/${filename}"; then
        echo "Failed to write event." >&2
        return 1
    fi

}

# ==================================================
# Public API
# ==================================================

#
# Creates a compact JSON payload.
#
event_payload() {

    jq \
        -c \
        -n \
        "$@"

}

#
# Creates a new event in the event queue.
#
event_emit() {

    local source="${1}"
    local event="${2}"
    local status="${3}"
    local payload="${4-}"
    

    if [[ -z "${payload}" ]]; then
        payload='{}'
    fi

    create_events_directory

    local event_id
    event_id=$(create_event_id)

    local timestamp
    timestamp=$(create_timestamp)

    local filename
    filename=$(create_filename \
        "${event_id}" \
        "${source}" \
        "${event}")

    write_event \
        "${filename}" \
        "${event_id}" \
        "${event}" \
        "${timestamp}" \
        "${source}" \
        "${status}" \
        "${payload}"

}