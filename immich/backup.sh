#!/usr/bin/env bash
set -euo pipefail

NFS_MOUNT="/mnt/truenas/immich"
UPLOAD_LOCATION="$NFS_MOUNT/immich_library"
BACKUP_PATH="$NFS_MOUNT/borgbackup"

export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes

if ! mountpoint -q "$NFS_MOUNT"; then
	echo "error: $NFS_MOUNT is not mounted, refusing to run" >&2
	exit 1
fi

mkdir -p "$UPLOAD_LOCATION/database_backup" "$BACKUP_PATH"

if ! borg info "$BACKUP_PATH" >/dev/null 2>&1; then
	borg init --encryption=none "$BACKUP_PATH"
fi

docker exec -t immich_postgres \
	pg_dumpall --clean --if-exists --username=postgres \
	>"$UPLOAD_LOCATION/database_backup/immich-database.sql"

borg create --stats "$BACKUP_PATH::{now}" "$UPLOAD_LOCATION" \
	--exclude "$UPLOAD_LOCATION/thumbs" \
	--exclude "$UPLOAD_LOCATION/encoded-video"
borg prune --keep-daily=7 --keep-weekly=4 --keep-monthly=3 "$BACKUP_PATH"
borg compact "$BACKUP_PATH"
