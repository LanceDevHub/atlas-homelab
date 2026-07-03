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

# ==================================================
# Functions
# ==================================================

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

    # Export all variables from the PostgreSQL .env file
    # so pg_dump can access them.
    set -a
    source "${POSTGRES_ENV}"
    set +a

    PGPASSWORD="${POSTGRES_PASSWORD}" \
    pg_dump \
        -h "${POSTGRES_HOST}" \
        -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" \
        -Fc \
        "${POSTGRES_DB}" \
        -f "${BACKUP_DIR}/postgres.dump"

    echo "PostgreSQL backup completed."
    echo
}

backup_n8n() {
    echo "==> Backing up n8n data..."

    mkdir -p "${BACKUP_DIR}/data"

    # Archive mode preserves permissions,
    # timestamps and symbolic links.
    cp -a "${DATA_DIR}/n8n" "${BACKUP_DIR}/data/"

    echo "n8n backup completed."
    echo
}

backup_env() {
    echo "==> Backing up environment files..."

    mkdir -p "${BACKUP_DIR}/env"

    # Ignore the pattern if no .env files exist.
    shopt -s nullglob

    for env_file in "${COMPOSE_DIR}"/*/.env; do
        service_name=$(basename "$(dirname "${env_file}")")

        cp "${env_file}" "${BACKUP_DIR}/env/${service_name}.env"

        echo "  ✓ ${service_name}.env"
    done

    # Restore default shell behavior.
    shopt -u nullglob

    echo
    echo "Environment files backup completed."
    echo
}

backup_certs() {
    echo "==> Backing up TLS certificates..."

    # Archive mode preserves permissions,
    # timestamps and symbolic links.
    cp -a "${CERTS_DIR}" "${BACKUP_DIR}/"

    echo "TLS certificates backup completed."
    echo
}

verify_backup() {
    echo "==> Verifying backup..."

    local errors=0

    # Verify backup metadata.
    if [[ -f "${BACKUP_DIR}/backup.info" ]]; then
        echo "  ✓ backup.info"
    else
        echo "  ✗ backup.info missing"
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

        # Abort immediately if the backup is incomplete.
        exit 1
    fi

    echo "Backup verification successful."
    echo
}

main() {
    echo
    echo "======================================="
    echo " Atlas Backup"
    echo "======================================="
    echo

    # Create backup directory
    create_backup_directory

    # Create backup metadata.
    create_backup_info

    # Backup application data.
    backup_postgres
    backup_n8n
    backup_env
    backup_certs

    # Verify backup integrity.
    verify_backup

    echo "======================================="
    echo " Backup completed successfully."
    echo "======================================="
}

main