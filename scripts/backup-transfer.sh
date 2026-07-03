#!/usr/bin/env bash

set -Eeuo pipefail

# ==================================================
# Configuration
# ==================================================

readonly BACKUP_ROOT="/opt/atlas/backups/daily"
readonly TRANSFER_TARGET="/mnt/atlas-backups"

check_mount() {
    echo "==> Checking backup destination..."

    if mountpoint -q "${TRANSFER_TARGET}"; then
        echo "Backup destination available."
        echo
    else
        echo "Backup destination unavailable."
        echo
        echo "Transfer skipped."
        exit 0
    fi
}

transfer_backups() {
    echo "==> Transferring backups..."

    local backup
    local backup_name
    local transferred=0
    local skipped=0
    local errors=0

    # Ignore the pattern if no backup directories exist.
    shopt -s nullglob

    for backup in "${BACKUP_ROOT}"/*; do

        # Skip everything except directories.
        [[ -d "${backup}" ]] || continue

        backup_name=$(basename "${backup}")

        if [[ -d "${TRANSFER_TARGET}/${backup_name}" ]]; then
            echo "  - ${backup_name} already exists"
            ((++skipped))
            continue
        fi

        if cp -a "${backup}" "${TRANSFER_TARGET}/"; then
            echo "  ✓ ${backup_name}"
            ((++transferred))
        else
            echo "  ✗ ${backup_name}"
            ((++errors))
        fi

    done

    # Restore default shell behavior.
    shopt -u nullglob

    echo
    echo "Transferred: ${transferred}"
    echo "Skipped: ${skipped}"

    if (( errors > 0 )); then
        echo "Errors: ${errors}"
        echo
        echo "Backup transfer failed."
        exit 1
    fi

    echo
    echo "Backup transfer completed."
    echo
}

verify_transfer() {
    echo "==> Verifying transfer..."

    local errors=0
    local backup_name

    for backup in "${BACKUP_ROOT}"/*; do

        backup_name=$(basename "${backup}")

        if [[ -d "${TRANSFER_TARGET}/${backup_name}" ]]; then
            echo "  ✓ ${backup_name}"
        else
            echo "  ✗ ${backup_name} missing"
            ((errors++))
        fi

    done

    echo

    if (( errors > 0 )); then
        echo "Transfer verification failed."
        exit 1
    fi

    echo "Transfer verification successful."
    echo
}


main() {

    echo
    echo "======================================="
    echo " Atlas Backup Transfer"
    echo "======================================="
    echo

    check_mount

    transfer_backups

    verify_transfer

    echo "======================================="
    echo " Backup transfer completed."
    echo "======================================="
}

main