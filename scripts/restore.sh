#!/usr/bin/env bash

# Exit immediately on errors (-e)
# Preserve error traps in functions (-E)
# Treat unset variables as errors (-u)
# Fail if any command in a pipeline fails (pipefail)
set -Eeuo pipefail

# Directory of this script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# get lib functions
source "${SCRIPT_DIR}/lib/events.sh"

# ==================================================
# Configuration
# ==================================================

# Backup
# Backup directory passed as first command-line argument.
readonly BACKUP_DIR="${1:-}"

readonly PRE_RESTORE_ROOT="/opt/atlas/backups/pre-restore"
readonly PRE_RESTORE_DIR="${PRE_RESTORE_ROOT}/$(date +"%Y-%m-%d_%H-%M-%S")"

# Atlas directories
readonly DATA_DIR="/opt/atlas/data"
readonly COMPOSE_DIR="/opt/atlas/compose"
readonly CERTS_DIR="/opt/atlas/certs"

# Compose projects
readonly POSTGRES_COMPOSE="${COMPOSE_DIR}/postgres/compose.yaml"
readonly N8N_COMPOSE="${COMPOSE_DIR}/n8n/compose.yaml"
readonly TRAEFIK_COMPOSE="${COMPOSE_DIR}/traefik/compose.yaml"

# PostgreSQL
readonly POSTGRES_ENV="${COMPOSE_DIR}/postgres/.env"
readonly POSTGRES_HOST="localhost"
readonly POSTGRES_PORT="5432"

# Backup format
readonly SUPPORTED_BACKUP_VERSION=1

# Files that must exist in every valid backup.
readonly REQUIRED_ENV_FILES=(
    postgres
    n8n
    traefik
)

readonly REQUIRED_CERT_FILES=(
    atlas.key
    atlas.crt
    atlas.cnf
)

# ==================================================
# Functions
# ==================================================

check_arguments() {
    if [[ -z "${BACKUP_DIR}" ]]; then
        echo "Usage:"
        echo "  restore.sh <backup-directory>"

        emit_restore_failed "check_arguments"
        return 1
    fi
}

verify_backup() {
    echo "==> Verifying backup..."

    local errors=0

    # Verify backup directory.
    if [[ ! -d "${BACKUP_DIR}" ]]; then
        echo "✗ Backup directory not found"

        emit_restore_failed "verify_backup"
        return 1
    fi

    # Verify metadata.
    if [[ -f "${BACKUP_DIR}/backup.info" ]]; then

        # Import backup metadata.
        source "${BACKUP_DIR}/backup.info"

        echo "  ✓ backup.info"

    else
        echo "✗ backup.info missing"

        emit_restore_failed "verify_backup"
        return 1
    fi

    # Verify backup version.
    if [[ "${BACKUP_VERSION}" == "${SUPPORTED_BACKUP_VERSION}" ]]; then
        echo "  ✓ Backup version supported"
    else
        echo "  ✗ Unsupported backup version: ${BACKUP_VERSION}"
        ((errors++))
    fi

    # Verify PostgreSQL dumps.
    shopt -s nullglob

    local postgres_dumps=("${BACKUP_DIR}"/postgres/*.dump)

    if (( ${#postgres_dumps[@]} > 0 )); then
        for dump_file in "${postgres_dumps[@]}"; do
            echo "  ✓ $(basename "${dump_file}")"
        done
    else
        echo "  ✗ No PostgreSQL dumps found"
        ((errors++))
    fi

    shopt -u nullglob

    # Verify n8n data.
    if [[ -d "${BACKUP_DIR}/data/n8n" ]]; then
        echo "  ✓ n8n data"
    else
        echo "  ✗ n8n data missing"
        ((errors++))
    fi

    # Verify environment files.
    for service in "${REQUIRED_ENV_FILES[@]}"; do
        if [[ -f "${BACKUP_DIR}/env/${service}.env" ]]; then
            echo "  ✓ ${service}.env"
        else
            echo "  ✗ ${service}.env missing"
            ((errors++))
        fi
    done

    # Verify TLS certificates.
    for file in "${REQUIRED_CERT_FILES[@]}"; do
        if [[ -f "${BACKUP_DIR}/certs/${file}" ]]; then
            echo "  ✓ ${file}"
        else
            echo "  ✗ ${file} missing"
            ((errors++))
        fi
    done

    echo

    if (( errors > 0 )); then
        echo "Backup verification failed."

        emit_restore_failed "verify_backup"
        return 1
    fi

    echo "Backup verification successful."
    echo
}

show_backup_information() {
    echo "Backup Information"
    echo "------------------"
    echo "Timestamp : ${TIMESTAMP}"
    echo "Hostname  : ${HOSTNAME}"
    echo "Version   : ${BACKUP_VERSION}"
    echo
}

confirm_restore() {

    echo "WARNING"
    echo
    echo "This operation will overwrite the current Atlas installation."
    echo "The operation cannot be undone."
    echo

    read -rp "Type YES to continue: " confirmation

    if [[ "${confirmation}" != "YES" ]]; then
        echo
        echo "Restore aborted."

        emit_restore_failed "confirm_restore"
        return 1
    fi

    echo
}

# Stop the compose project only if a container is currently running.
stop_service() {
    local service_name="$1"
    local compose_file="$2"

    if [[ -n "$(docker compose -f "${compose_file}" ps --status running -q)" ]]; then
        echo "Stopping ${service_name}..."

        if ! docker compose -f "${compose_file}" down; then
            emit_restore_failed "stop_services"
            return 1
        fi

        echo "${service_name} stopped successfully."
    else
        echo "${service_name} is already stopped."
    fi
}

start_service() {

    local service_name="$1"
    local compose_file="$2"

    if [[ -z "$(docker compose -f "${compose_file}" ps --status running -q)" ]]; then
        echo "Starting ${service_name}..."

        if ! docker compose -f "${compose_file}" up -d; then
            emit_restore_failed "start_services"
            return 1
        fi

        echo "${service_name} started successfully."
    else
        echo "${service_name} is already running."
    fi
}


stop_services() {
    echo "==> Stopping Atlas services..."

    if ! stop_service "n8n" "${N8N_COMPOSE}"; then
        return 1
    fi

    if ! stop_service "PostgreSQL" "${POSTGRES_COMPOSE}"; then
        return 1
    fi

    if ! stop_service "Traefik" "${TRAEFIK_COMPOSE}"; then
        return 1
    fi

    echo
    echo "All services stopped."
    echo
}

start_services() {
    echo "==> Starting Atlas services..."

    if ! start_service "PostgreSQL" "${POSTGRES_COMPOSE}"; then
        return 1
    fi

    if ! start_service "n8n" "${N8N_COMPOSE}"; then
        return 1
    fi

    if ! start_service "Traefik" "${TRAEFIK_COMPOSE}"; then
        return 1
    fi

    echo
    echo "All services started."
    echo
}


backup_current_state() {
    echo "==> Creating pre-restore backup..."

    if ! mkdir -p "${PRE_RESTORE_DIR}"; then
        emit_restore_failed "backup_current_state"
        return 1
    fi

    if ! mkdir -p "${PRE_RESTORE_DIR}/data"; then
        emit_restore_failed "backup_current_state"
        return 1
    fi

    if ! cp -a "${DATA_DIR}/n8n" "${PRE_RESTORE_DIR}/data/"; then
        emit_restore_failed "backup_current_state"
        return 1
    fi

    if ! mkdir -p "${PRE_RESTORE_DIR}/env"; then
        emit_restore_failed "backup_current_state"
        return 1
    fi

    shopt -s nullglob

    for env_file in "${COMPOSE_DIR}"/*/.env; do
        local service_name
        service_name=$(basename "$(dirname "${env_file}")")

        if ! cp "${env_file}" "${PRE_RESTORE_DIR}/env/${service_name}.env"; then
            shopt -u nullglob
            emit_restore_failed "backup_current_state"
            return 1
        fi
    done

    shopt -u nullglob

    if ! cp -a "${CERTS_DIR}" "${PRE_RESTORE_DIR}/"; then
        emit_restore_failed "backup_current_state"
        return 1
    fi

    echo "Pre-restore backup created:"
    echo "  ${PRE_RESTORE_DIR}"
    echo
}


load_postgres_env() {

    # Export all variables from the PostgreSQL .env file.
    set -a

    if ! source "${POSTGRES_ENV}"; then
        set +a
        emit_restore_failed "restore_postgres"
        return 1
    fi

    set +a
}

start_postgres() {
    echo "==> Preparing PostgreSQL..."

    if ! load_postgres_env; then
        return 1
    fi

    if ! start_service "PostgreSQL" "${POSTGRES_COMPOSE}"; then
        return 1
    fi

    echo "Waiting for PostgreSQL..."

    local retries=30

    until PGPASSWORD="${POSTGRES_PASSWORD}" \
        pg_isready \
            -h "${POSTGRES_HOST}" \
            -p "${POSTGRES_PORT}" \
            -U "${POSTGRES_USER}" >/dev/null 2>&1
    do
        ((retries--))

        if (( retries == 0 )); then
            emit_restore_failed "restore_postgres"
            return 1
        fi

        sleep 1
    done

    echo "PostgreSQL is ready."
    echo
}

restore_postgres() {
    echo "==> Restoring PostgreSQL..."

    # Start PostgreSQL and wait until it is ready.
    if ! start_postgres; then
        return 1
    fi

    # Restore every database dump.
    for dump_file in "${BACKUP_DIR}"/postgres/*.dump; do
        local database

        database=$(basename "${dump_file}" .dump)

        if ! recreate_database "${database}"; then
            return 1
        fi

        if ! restore_database "${database}" "${dump_file}"; then
            return 1
        fi
    done

    echo "PostgreSQL restore completed."
    echo
}

recreate_database() {
    local database="$1"

    echo "==> Recreating database '${database}'..."

    if ! PGPASSWORD="${POSTGRES_PASSWORD}" \
        psql \
            -v ON_ERROR_STOP=1 \
            -h "${POSTGRES_HOST}" \
            -p "${POSTGRES_PORT}" \
            -U "${POSTGRES_USER}" \
            -d postgres <<EOF
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = '${database}'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS ${database};

CREATE DATABASE ${database};
EOF
    then
        emit_restore_failed "restore_postgres"
        return 1
    fi

    echo "Database '${database}' recreated."
    echo
}

restore_database() {
    local database="$1"
    local dump_file="$2"

    echo "==> Restoring database '${database}'..."

    if ! PGPASSWORD="${POSTGRES_PASSWORD}" \
        pg_restore \
            -h "${POSTGRES_HOST}" \
            -p "${POSTGRES_PORT}" \
            -U "${POSTGRES_USER}" \
            -d "${database}" \
            "${dump_file}"
    then
        emit_restore_failed "restore_postgres"
        return 1
    fi

    echo "Database '${database}' restored."
    echo
}

restore_n8n() {
    echo "==> Restoring n8n data..."

    if ! rm -rf "${DATA_DIR}/n8n"; then
        emit_restore_failed "restore_n8n"
        return 1
    fi

    if ! cp -a "${BACKUP_DIR}/data/n8n" "${DATA_DIR}/"; then
        emit_restore_failed "restore_n8n"
        return 1
    fi

    echo "n8n data restored."
    echo
}

restore_envs() {
    echo "==> Restoring environment files..."

    shopt -s nullglob

    for env_file in "${BACKUP_DIR}/env/"*.env; do
        local service_name
        service_name=$(basename "${env_file}" .env)

        if ! cp "${env_file}" "${COMPOSE_DIR}/${service_name}/.env"; then
            shopt -u nullglob
            emit_restore_failed "restore_envs"
            return 1
        fi

        echo "  ✓ ${service_name}.env"
    done

    shopt -u nullglob

    echo
    echo "Environment files restored."
    echo
}

restore_certs() {
    echo "==> Restoring TLS certificates..."

    if ! rm -rf "${CERTS_DIR}"; then
        emit_restore_failed "restore_certs"
        return 1
    fi

    if ! mkdir -p "${CERTS_DIR}"; then
        emit_restore_failed "restore_certs"
        return 1
    fi

    if ! cp -a "${BACKUP_DIR}/certs/." "${CERTS_DIR}/"; then
        emit_restore_failed "restore_certs"
        return 1
    fi

    echo "TLS certificates restored."
    echo
}

is_service_running() {
    local compose_file="${1:?Missing compose file}"

    [[ -n "$(docker compose -f "${compose_file}" ps --status running -q)" ]]
}

verify_restore() {
    echo "==> Verifying restore..."

    local errors=0

    if is_service_running "${POSTGRES_COMPOSE}"; then
        echo "  ✓ PostgreSQL running"
    else
        echo "  ✗ PostgreSQL is not running"
        ((errors++))
    fi

    if is_service_running "${N8N_COMPOSE}"; then
        echo "  ✓ n8n running"
    else
        echo "  ✗ n8n is not running"
        ((errors++))
    fi

    if is_service_running "${TRAEFIK_COMPOSE}"; then
        echo "  ✓ Traefik running"
    else
        echo "  ✗ Traefik is not running"
        ((errors++))
    fi

    echo

    if (( errors > 0 )); then
        echo "Restore verification failed."

        emit_restore_failed "verify_restore"
        return 1
    fi

    echo "Restore verification successful."
    echo
}

emit_restore_failed() {

    local step="${1}"

    local payload

    payload=$(
        event_payload \
            --arg step "${step}" \
            '{
                step: $step
            }'
    )

    event_emit \
        "atlas-restore" \
        "restore.failed" \
        "error" \
        "${payload}"

}



main() {


    event_emit \
    "atlas-restore" \
    "restore.started" \
    "info"

    echo
    echo "======================================="
    echo " Atlas Restore"
    echo "======================================="
    echo

    # Validate user input.
    check_arguments

    # Verify backup integrity.
    verify_backup

    # Display backup metadata.
    show_backup_information

    # Ask the user for confirmation.
    confirm_restore

    # Stop all running Atlas services.
    stop_services

    # Create a rollback backup of the current system state.
    backup_current_state

    # Restore PostgreSQL database.
    restore_postgres

    # Restore application data.
    restore_n8n

    # Restore configuration.
    restore_envs
    restore_certs

    # Start all Atlas services.
    start_services

    verify_restore

    local payload

    payload=$(
        event_payload \
            --arg backup "$(basename "${BACKUP_DIR}")" \
            '{
                backup: $backup
            }'
    )

    event_emit \
        "atlas-restore" \
        "restore.completed" \
        "success" \
        "${payload}"



    echo "======================================="
    echo " Restore completed successfully."
    echo "======================================="
}

main