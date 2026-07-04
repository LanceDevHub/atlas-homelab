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

    rm -rf "${BACKUP_DIR}"

    echo "Incomplete backup removed."
}

create_backup_directory() {
    echo "==> Creating backup directory..."

    mkdir -p "${BACKUP_DIR}"

    echo "Backup directory: ${BACKUP_DIR}"
    echo
}

create_backup_info() {
    echo "==> Creating backup metadata..."

    cat > "${BACKUP_DIR}/backup.info" <<EOF
BACKUP_VERSION=1
TIMESTAMP=${TIMESTAMP}
HOSTNAME=$(hostname)
EOF

    echo "Backup metadata created."
    echo
}

backup_postgres() {
    echo "==> Backing up PostgreSQL..."

    set -a
    source "${POSTGRES_ENV}"
    set +a

    mkdir -p "${BACKUP_DIR}/postgres"

    mapfile -t databases < <(
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
    )

    for database in "${databases[@]}"; do
        echo "  ✓ ${database}"

        PGPASSWORD="${POSTGRES_PASSWORD}" \
        pg_dump \
            -h "${POSTGRES_HOST}" \
            -p "${POSTGRES_PORT}" \
            -U "${POSTGRES_USER}" \
            -Fc \
            "${database}" \
            -f "${BACKUP_DIR}/postgres/${database}.dump"
    done

    echo
    echo "PostgreSQL backup completed."
    echo
}

backup_n8n() {
    echo "==> Backing up n8n data..."

    mkdir -p "${BACKUP_DIR}/data"
    cp -a "${DATA_DIR}/n8n" "${BACKUP_DIR}/data/"

    echo "n8n backup completed."
    echo
}

backup_env() {
    echo "==> Backing up environment files..."

    mkdir -p "${BACKUP_DIR}/env"

    shopt -s nullglob

    for env_file in "${COMPOSE_DIR}"/*/.env; do
        service_name=$(basename "$(dirname "${env_file}")")
        cp "${env_file}" "${BACKUP_DIR}/env/${service_name}.env"
        echo "  ✓ ${service_name}.env"
    done

    shopt -u nullglob

    echo
    echo "Environment files backup completed."
    echo
}

backup_certs() {
    echo "==> Backing up TLS certificates..."

    cp -a "${CERTS_DIR}" "${BACKUP_DIR}/"

    echo "TLS certificates backup completed."
    echo
}

verify_backup() {
    echo "==> Verifying backup..."

    local errors=0

    if [[ -f "${BACKUP_DIR}/backup.info" ]]; then
        echo "  ✓ backup.info"
    else
        echo "  ✗ backup.info missing"
        ((errors++))
    fi

    if compgen -G "${BACKUP_DIR}/postgres/*.dump" > /dev/null; then
        for dump_file in "${BACKUP_DIR}"/postgres/*.dump; do
            echo "  ✓ $(basename "${dump_file}")"
        done
    else
        echo "  ✗ No PostgreSQL dumps found"
        ((errors++))
    fi

    if [[ -d "${BACKUP_DIR}/data/n8n" ]]; then
        echo "  ✓ n8n data"
    else
        echo "  ✗ n8n data missing"
        ((errors++))
    fi

    for service in "${REQUIRED_ENV_FILES[@]}"; do
        if [[ -f "${BACKUP_DIR}/env/${service}.env" ]]; then
            echo "  ✓ ${service}.env"
        else
            echo "  ✗ ${service}.env missing"
            ((errors++))
        fi
    done

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
        return 1
    fi

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
        rm -rf "${backups[i]}"
    done

    echo
    echo "Backup rotation completed."
    echo
}

main() {
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

    trap - ERR

    echo "======================================="
    echo " Backup completed successfully."
    echo "======================================="
}

main
