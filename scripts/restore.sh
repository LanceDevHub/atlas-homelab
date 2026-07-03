#!/usr/bin/env bash

# Exit immediately on errors (-e)
# Preserve error traps in functions (-E)
# Treat unset variables as errors (-u)
# Fail if any command in a pipeline fails (pipefail)
set -Eeuo pipefail

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
        exit 1
    fi
}

verify_backup() {
    echo "==> Verifying backup..."

    local errors=0

    # Verify backup directory.
    if [[ ! -d "${BACKUP_DIR}" ]]; then
        echo "  ✗ Backup directory not found"
        exit 1
    fi

    # Verify metadata.
    if [[ -f "${BACKUP_DIR}/backup.info" ]]; then

        # Import backup metadata.
        source "${BACKUP_DIR}/backup.info"

        echo "  ✓ backup.info"

    else
        echo "  ✗ backup.info missing"
        exit 1
    fi

    # Verify backup version.
    if [[ "${BACKUP_VERSION}" == "${SUPPORTED_BACKUP_VERSION}" ]]; then
        echo "  ✓ Backup version supported"
    else
        echo "  ✗ Unsupported backup version: ${BACKUP_VERSION}"
        ((errors++))
    fi

    # Verify PostgreSQL dump.
    if [[ -s "${BACKUP_DIR}/postgres.dump" ]]; then
        echo "  ✓ PostgreSQL dump"
    else
        echo "  ✗ PostgreSQL dump missing"
        ((errors++))
    fi

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
        exit 1
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
        exit 1
    fi

    echo
}

# Stop the compose project only if a container is currently running.
stop_service() {
    local service_name="$1"
    local compose_file="$2"

    if [[ -n "$(docker compose -f "${compose_file}" ps --status running -q)" ]]; then
        echo "Stopping ${service_name}..."

        docker compose -f "${compose_file}" down

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

        docker compose -f "${compose_file}" up -d

        echo "${service_name} started successfully."
    else
        echo "${service_name} is already running."
    fi
}


stop_services() {
    echo "==> Stopping Atlas services..."

    stop_service "n8n" "${N8N_COMPOSE}"
    stop_service "PostgreSQL" "${POSTGRES_COMPOSE}"
    stop_service "Traefik" "${TRAEFIK_COMPOSE}"

    echo
    echo "All services stopped."
    echo
}

start_services() {
    echo "==> Starting Atlas services..."

    start_service "PostgreSQL" "${POSTGRES_COMPOSE}"
    start_service "n8n" "${N8N_COMPOSE}"
    start_service "Traefik" "${TRAEFIK_COMPOSE}"

    echo
    echo "All services started."
    echo
}


backup_current_state() {
    echo "==> Creating pre-restore backup..."

    mkdir -p "${PRE_RESTORE_DIR}"

    # Backup n8n data
    mkdir -p "${PRE_RESTORE_DIR}/data"

    cp -a "${DATA_DIR}/n8n" "${PRE_RESTORE_DIR}/data/"

    # Backup environment files
    mkdir -p "${PRE_RESTORE_DIR}/env"

    shopt -s nullglob

    for env_file in "${COMPOSE_DIR}"/*/.env; do
        service_name=$(basename "$(dirname "${env_file}")")

        cp "${env_file}" "${PRE_RESTORE_DIR}/env/${service_name}.env"
    done

    shopt -u nullglob

    # Backup TLS certificates
    cp -a "${CERTS_DIR}" "${PRE_RESTORE_DIR}/"

    echo "Pre-restore backup created:"
    echo "  ${PRE_RESTORE_DIR}"
    echo
}

restore_postgres() {
    echo "==> Restoring PostgreSQL..."

    # Start PostgreSQL and wait until it is ready.
    start_postgres

    # Recreate the target database.
    recreate_database

    # Restore the database dump.
    restore_database

    echo "PostgreSQL restore completed."
    echo
}

load_postgres_env() {

    # Export all variables from the PostgreSQL .env file.
    set -a
    source "${POSTGRES_ENV}"
    set +a

}

start_postgres() {
    echo "==> Preparing PostgreSQL..."

    load_postgres_env

    start_service "PostgreSQL" "${POSTGRES_COMPOSE}"

    echo "Waiting for PostgreSQL..."

    until PGPASSWORD="${POSTGRES_PASSWORD}" \
        pg_isready \
        -h "${POSTGRES_HOST}" \
        -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" >/dev/null 2>&1
    do
        sleep 1
    done

    echo "PostgreSQL is ready."
    echo
}

recreate_database() {
    echo "==> Recreating PostgreSQL database..."

    PGPASSWORD="${POSTGRES_PASSWORD}" \
    psql \
        -v ON_ERROR_STOP=1 \
        -h "${POSTGRES_HOST}" \
        -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" \
        -d postgres <<EOF
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = '${POSTGRES_DB}'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS ${POSTGRES_DB};

CREATE DATABASE ${POSTGRES_DB};
EOF

    echo "Database recreated."
    echo
}

restore_database() {
    echo "==> Restoring PostgreSQL database..."

    PGPASSWORD="${POSTGRES_PASSWORD}" \
    pg_restore \
        -h "${POSTGRES_HOST}" \
        -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DB}" \
        "${BACKUP_DIR}/postgres.dump"

    echo "PostgreSQL database restored."
    echo
}

restore_n8n() {
    echo "==> Restoring n8n data..."

    # Remove current n8n data.
    rm -rf "${DATA_DIR}/n8n"

    # Restore n8n data from the backup.
    cp -a "${BACKUP_DIR}/data/n8n" "${DATA_DIR}/"

    echo "n8n data restored."
    echo
}

restore_envs() {
    echo "==> Restoring environment files..."

    shopt -s nullglob

    for env_file in "${BACKUP_DIR}/env/"*.env; do
    # Use the backup filename as the service name.
        service_name=$(basename "${env_file}" .env)

        cp "${env_file}" "${COMPOSE_DIR}/${service_name}/.env"

        echo "  ✓ ${service_name}.env"
    done

    shopt -u nullglob

    echo
    echo "Environment files restored."
    echo
}

restore_certs() {
    echo "==> Restoring TLS certificates..."

    # Remove current certs.
    rm -rf "${CERTS_DIR}"

    # Restore certs from the backup.
    cp -a "${BACKUP_DIR}/certs/." "${CERTS_DIR}/"

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

        # Abort if one or more services failed to start.
        exit 1
    fi

    echo "Restore verification successful."
    echo
}



main() {

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


    echo "======================================="
    echo " Restore completed successfully."
    echo "======================================="
}

main