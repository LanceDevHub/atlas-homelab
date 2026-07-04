#!/usr/bin/env bash

# Exit immediately on errors (-e)
# Preserve error traps in functions (-E)
# Treat unset variables as errors (-u)
# Fail if any command in a pipeline fails (pipefail)
set -Eeuo pipefail

# get lib functions
source "./lib/events.sh"

# ==================================================
# Configuration
# ==================================================

# Backup
readonly BACKUP_ROOT="/opt/atlas/backups/daily"
readonly TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
readonly BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

# Atlas directories
readonly DATA_DIR="/opt/atlas/data"
readonly COMPOSE_DIR="/opt/atlas/compose"
readonly CERTS_DIR="/opt/atlas/certs"

# PostgreSQL
readonly POSTGRES_ENV="${COMPOSE_DIR}/postgres/.env"
readonly POSTGRES_HOST="localhost"
readonly POSTGRES_PORT="5432"

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

# Backup retention
readonly DAILY_RETENTION=7

# ==================================================
# Functions
# ==================================================

cleanup_failed_backup() {
    echo
    echo "Backup failed."
    echo "Removing incomplete backup..."

    rm -rf "${BACKUP_DIR}" || true

    echo "Incomplete backup removed."
}

create_backup_directory() {
    echo "==> Creating backup directory..."

    if ! mkdir -p "${BACKUP_DIR}"; then
        emit_backup_failed "create_backup_directory"
        return 1
    fi

    echo "Backup directory: ${BACKUP_DIR}"
    echo
}

create_backup_info() {
    echo "==> Creating backup metadata..."

    if ! cat > "${BACKUP_DIR}/backup.info" <<EOF
BACKUP_VERSION=1
TIMESTAMP=${TIMESTAMP}
HOSTNAME=$(hostname)
EOF
    then
        emit_backup_failed "create_backup_info"
        return 1
    fi

    echo "Backup metadata created."
    echo
}

backup_postgres() {
    echo "==> Backing up PostgreSQL..."

    set -a
    if ! source "${POSTGRES_ENV}"; then
        set +a
        emit_backup_failed "backup_postgres"
        return 1
    fi
    set +a

    if ! mkdir -p "${BACKUP_DIR}/postgres"; then
        emit_backup_failed "backup_postgres"
        return 1
    fi

    if ! mapfile -t databases < <(
        PGPASSWORD="${POSTGRES_PASSWORD}" \
        psql \
            -h "${POSTGRES_HOST}" \
            -p "${POSTGRES_PORT}" \
            -U "${POSTGRES_USER}" \
            -d postgres \
            -At \
            -c "SELECT datname
                FROM pg_database
                WHERE datistemplate = false
                AND datname <> 'postgres';"
    ); then
        emit_backup_failed "backup_postgres"
        return 1
    fi

    for database in "${databases[@]}"; do
        echo "  ✓ ${database}"

        if ! PGPASSWORD="${POSTGRES_PASSWORD}" \
            pg_dump \
                -h "${POSTGRES_HOST}" \
                -p "${POSTGRES_PORT}" \
                -U "${POSTGRES_USER}" \
                -Fc \
                "${database}" \
                -f "${BACKUP_DIR}/postgres/${database}.dump"
        then
            emit_backup_failed "backup_postgres"
            return 1
        fi
    done

    echo
    echo "PostgreSQL backup completed."
    echo
}

backup_n8n() {
    echo "==> Backing up n8n data..."

    if ! mkdir -p "${BACKUP_DIR}/data"; then
        emit_backup_failed "backup_n8n"
        return 1
    fi

    if ! cp -a "${DATA_DIR}/n8n" "${BACKUP_DIR}/data/"; then
        emit_backup_failed "backup_n8n"
        return 1
    fi

    echo "n8n backup completed."
    echo
}

backup_env() {
    echo "==> Backing up environment files..."

    if ! mkdir -p "${BACKUP_DIR}/env"; then
        emit_backup_failed "backup_env"
        return 1
    fi

    shopt -s nullglob

    for env_file in "${COMPOSE_DIR}"/*/.env; do
        service_name=$(basename "$(dirname "${env_file}")")
        if ! cp "${env_file}" "${BACKUP_DIR}/env/${service_name}.env"; then
            emit_backup_failed "backup_env"
            return 1
        fi

        echo "  ✓ ${service_name}.env"
    done

    shopt -u nullglob

    echo
    echo "Environment files backup completed."
    echo
}

backup_certs() {
    echo "==> Backing up TLS certificates..."

    if ! cp -a "${CERTS_DIR}" "${BACKUP_DIR}/"; then
        emit_backup_failed "backup_certs"
        return 1
    fi

    echo "TLS certificates backup completed."
    echo
}

emit_backup_failed() {

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
        "atlas-backup" \
        "backup.failed" \
        "error" \
        "${payload}"

}

verify_backup() {
    echo "==> Verifying backup..."

    if [[ -f "${BACKUP_DIR}/backup.info" ]]; then
        echo "  ✓ backup.info"
    else
        echo "  ✗ backup.info missing"

        return 1
    fi

    if compgen -G "${BACKUP_DIR}/postgres/*.dump" > /dev/null; then
        for dump_file in "${BACKUP_DIR}"/postgres/*.dump; do
            echo "  ✓ $(basename "${dump_file}")"
        done
    else
        echo "  ✗ No PostgreSQL dumps found"

        return 1
    fi

    if [[ -d "${BACKUP_DIR}/data/n8n" ]]; then
        echo "  ✓ n8n data"
    else
        echo "  ✗ n8n data missing"

        return 1
    fi

    for service in "${REQUIRED_ENV_FILES[@]}"; do
        if [[ -f "${BACKUP_DIR}/env/${service}.env" ]]; then
            echo "  ✓ ${service}.env"
        else
            echo "  ✗ ${service}.env missing"

            return 1
        fi
    done

    for file in "${REQUIRED_CERT_FILES[@]}"; do
        if [[ -f "${BACKUP_DIR}/certs/${file}" ]]; then
            echo "  ✓ ${file}"
        else
            echo "  ✗ ${file} missing"

            return 1
        fi
    done

    echo
    echo "Backup verification successful."
    echo
}

rotate_backups() {
    echo "==> Rotating backups..."

    mapfile -t backups < <(
        find "${BACKUP_ROOT}" -mindepth 1 -maxdepth 1 -type d | sort
    )

    local backup_count=${#backups[@]}

    if (( backup_count <= DAILY_RETENTION )); then
        echo "No old backups to remove."
        echo
        return
    fi

    local backups_to_delete=$((backup_count - DAILY_RETENTION))

    for ((i=0; i<backups_to_delete; i++)); do
        echo "Deleting backup:"
        echo "  $(basename "${backups[i]}")"
        if ! rm -rf "${backups[i]}"; then
            emit_backup_failed "rotate_backups"
            return 1
        fi
    done

    echo
    echo "Backup rotation completed."
    echo
}

main() {

    event_emit \
    "atlas-backup" \
    "backup.started" \
    "info"

    trap cleanup_failed_backup ERR

    echo
    echo "======================================="
    echo " Atlas Backup"
    echo "======================================="
    echo

    create_backup_directory
    create_backup_info

    backup_postgres
    backup_n8n
    backup_env
    backup_certs

    verify_backup
    rotate_backups

    local payload

    payload=$(
        event_payload \
            --arg directory "${TIMESTAMP}" \
            '{
                directory: $directory
            }'
    )

    event_emit \
        "atlas-backup" \
        "backup.completed" \
        "success" \
        "${payload}"

    trap - ERR

    echo "======================================="
    echo " Backup completed successfully."
    echo "======================================="
}

main
