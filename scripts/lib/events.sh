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

    date +"%Y-%m-%dT%H:%M:%SZ"

}

create_filename() {

    date -u +"%Y%m%dT%H%M%S%N.json"

}

write_event() {

    local filename="${1}"
    local event="${2}"
    local timestamp="${3}"
    local source="${4}"
    local status="${5}"
    local payload="${6}"

    if ! jq \
        -n \
        --arg event "${event}" \
        --arg timestamp "${timestamp}" \
        --arg source "${source}" \
        --arg status "${status}" \
        --argjson payload "${payload}" \
        '{
            event: $event,
            timestamp: $timestamp,
            source: $source,
            status: $status,
            payload: $payload
        }' \
        > "${EVENTS_DIR}/${filename}"
    then
        return 1
    fi

}

# ==================================================
# Public API
# ==================================================

event_payload() {

    jq \
        -c \
        -n \
        "$@"

}

event_emit() {

    local source="${1}"
    local event="${2}"
    local status="${3}"
    local payload="${4-}"

    if [[ -z "${payload}" ]]; then
        payload='{}'
    fi

    create_events_directory || return 1

    local timestamp
    timestamp=$(create_timestamp)

    local filename
    filename=$(create_filename)

    write_event \
        "${filename}" \
        "${event}" \
        "${timestamp}" \
        "${source}" \
        "${status}" \
        "${payload}" || return 1

}