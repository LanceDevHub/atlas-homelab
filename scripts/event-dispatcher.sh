#!/usr/bin/env bash
readonly EVENTS_DIR="/opt/atlas/events"

readonly WEBHOOK_HOST="n8n.home.arpa"
readonly WEBHOOK_URL="https://${WEBHOOK_HOST}/webhook/atlas-events"

readonly HTTP_SUCCESS="200"
readonly HTTP_CREATED="201"

check_dependencies() {
    echo "==> Checking dependencies..."

    if ! command -v curl >/dev/null 2>&1; then
        echo "curl is not installed."
        exit 1
    fi

    if [[ ! -d "${EVENTS_DIR}" ]]; then
        echo "Event directory does not exist."
        exit 1
    fi

    echo "Dependencies available."
    echo
}

dispatch_event() {

    local event_file="${1}"

    curl \
        --silent \
        --show-error \
        --output /dev/null \
        --write-out "%{http_code}" \
        --resolve "${WEBHOOK_HOST}:443:127.0.0.1" \
        --insecure \
        --header "Content-Type: application/json" \
        --data @"${event_file}" \
        "${WEBHOOK_URL}"

}

dispatch_events() {
    echo "==> Dispatching events..."

    local event_file
    local status

    shopt -s nullglob

    for event_file in "${EVENTS_DIR}"/*.json; do

        echo "  -> $(basename "${event_file}")"

        status=$(dispatch_event "${event_file}")

        if [[ "${status}" == "${HTTP_SUCCESS}" ]] || \
           [[ "${status}" == "${HTTP_CREATED}" ]]; then

            cleanup_success "${event_file}"
            echo "     ✓ Dispatched"

        else

            echo "     ✗ HTTP ${status}"

        fi

    done

    shopt -u nullglob

    echo
}

cleanup_success() {

    local event_file="${1}"

    rm -f "${event_file}"

}



main() {

    echo
    echo "======================================="
    echo " Atlas Event Dispatcher"
    echo "======================================="
    echo

    check_dependencies

    dispatch_events

    echo "======================================="
    echo " Event dispatch completed."
    echo "======================================="
}

main