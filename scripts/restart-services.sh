#!/usr/bin/env bash

set -Eeuo pipefail

# ==================================================
# Configuration
# ==================================================

readonly COMPOSE_DIR="/opt/atlas/compose"

readonly POSTGRES_COMPOSE="${COMPOSE_DIR}/postgres/compose.yaml"
readonly N8N_COMPOSE="${COMPOSE_DIR}/n8n/compose.yaml"
readonly TRAEFIK_COMPOSE="${COMPOSE_DIR}/traefik/compose.yaml"

# ==================================================
# Functions
# ==================================================

stop_service() {

    local service_name="${1}"
    local compose_file="${2}"

    echo "Stopping ${service_name}..."

    docker compose -f "${compose_file}" down

    echo "${service_name} stopped."
    echo
}

start_service() {

    local service_name="${1}"
    local compose_file="${2}"

    echo "Starting ${service_name}..."

    docker compose -f "${compose_file}" up -d

    echo "${service_name} started."
    echo
}

main() {

    echo
    echo "======================================="
    echo " Atlas Service Restart"
    echo "======================================="
    echo

    # Stop services
    stop_service "n8n" "${N8N_COMPOSE}"
    stop_service "Traefik" "${TRAEFIK_COMPOSE}"
    stop_service "PostgreSQL" "${POSTGRES_COMPOSE}"

    # Start services
    start_service "PostgreSQL" "${POSTGRES_COMPOSE}"
    start_service "n8n" "${N8N_COMPOSE}"
    start_service "Traefik" "${TRAEFIK_COMPOSE}"

    echo "======================================="
    echo " All services restarted successfully."
    echo "======================================="
}

main