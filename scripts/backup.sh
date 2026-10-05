#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
workspace_root=$(dirname -- "$script_dir")
config_file=${BACKUP_CONFIG:-"$workspace_root/.env"}

if [[ -f "$config_file" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "$config_file"
    set +a
fi

: "${BACKUP_TARGET:?Set BACKUP_TARGET in $config_file or the environment}"
command -v rsync >/dev/null || {
    echo "rsync is required" >&2
    exit 127
}

dry_run=0
delete=${BACKUP_DELETE:-0}
for argument in "$@"; do
    case "$argument" in
        --dry-run) dry_run=1 ;;
        --delete) delete=1 ;;
        *) echo "unknown option: $argument" >&2; exit 2 ;;
    esac
done

# Snapshot Forgejo's live database and repositories before copying the tree.
# A dry run never mutates the source by creating a fresh dump.
if [[ $dry_run -eq 0 && ${SKIP_FORGE_DUMP:-0} != 1 ]]; then
    make -C "$workspace_root/forge" backup
fi

rsync_args=(
    --archive
    --hard-links
    --partial
    --human-readable
    --info=stats2
)

if [[ $dry_run -eq 1 ]]; then
    rsync_args+=(--dry-run --itemize-changes)
fi
if [[ $delete -eq 1 ]]; then
    rsync_args+=(--delete-delay)
fi
if [[ -n ${BACKUP_RSYNC_RSH:-} ]]; then
    rsync_args+=(--rsh "$BACKUP_RSYNC_RSH")
fi

echo "Backing up $workspace_root/ to $BACKUP_TARGET/"
rsync "${rsync_args[@]}" -- "$workspace_root/" "$BACKUP_TARGET/"
