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

readonly BACKUP_ROOT="/opt/atlas/backups/daily"
readonly TRANSFER_TARGET="/mnt/atlas-backups"

# ==================================================
# Functions
# ==================================================

emit_transfer_failed() {

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
        "atlas-transfer" \
        "transfer.failed" \
        "error" \
        "${payload}"

}

check_mount() {
    echo "==> Checking backup destination..."

    if mountpoint -q "${TRANSFER_TARGET}"; then
        echo "Backup destination available."
        echo
        return 0
    fi

    echo "Backup destination unavailable."
    echo
    echo "Transfer skipped."

    emit_transfer_failed "check_mount"
    return 1
}

transfer_backups() {
    echo "==> Transferring backups..."

    local backup
    local backup_name
    local transferred=0
    local skipped=0

    shopt -s nullglob

    for backup in "${BACKUP_ROOT}"/*; do

        [[ -d "${backup}" ]] || continue

        backup_name=$(basename "${backup}")

        if [[ -d "${TRANSFER_TARGET}/${backup_name}" ]]; then
            echo "  - ${backup_name} already exists"
            ((++skipped))
            continue
        fi

        if ! cp -a "${backup}" "${TRANSFER_TARGET}/"; then
            shopt -u nullglob
            emit_transfer_failed "transfer_backups"
            return 1
        fi

        echo "  ✓ ${backup_name}"
        ((++transferred))

    done

    shopt -u nullglob

    echo
    echo "Transferred: ${transferred}"
    echo "Skipped: ${skipped}"
    echo
    echo "Backup transfer completed."
    echo
}

verify_transfer() {
    echo "==> Verifying transfer..."

    shopt -s nullglob

    for backup in "${BACKUP_ROOT}"/*; do

        [[ -d "${backup}" ]] || continue

        local backup_name
        backup_name=$(basename "${backup}")

        if [[ -d "${TRANSFER_TARGET}/${backup_name}" ]]; then
            echo "  ✓ ${backup_name}"
        else
            shopt -u nullglob

            echo "  ✗ ${backup_name} missing"

            emit_transfer_failed "verify_transfer"
            return 1
        fi

    done

    shopt -u nullglob

    echo
    echo "Transfer verification successful."
    echo
}

main() {

    event_emit \
        "atlas-transfer" \
        "transfer.started" \
        "info"

    echo
    echo "======================================="
    echo " Atlas Backup Transfer"
    echo "======================================="
    echo

    check_mount
    transfer_backups
    verify_transfer

    local payload

    payload=$(
        event_payload \
            '{
            }'
    )

    event_emit \
        "atlas-transfer" \
        "transfer.completed" \
        "success" \
        "${payload}"

    echo "======================================="
    echo " Backup transfer completed."
    echo "======================================="
}

main