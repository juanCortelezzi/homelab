#!/usr/bin/bash

UPLOAD_LOCATION="./immich_volumes/immich_library"
BACKUP_PATH="./borgbackup"

# Backup Immich database
docker exec -t immich_postgres \
	pg_dumpall --clean --if-exists --username=postgres > "$UPLOAD_LOCATION"/database_backup/immich-database.sql

### Append to local Borg repository
borg create "$BACKUP_PATH::{now}" "$UPLOAD_LOCATION" --exclude "$UPLOAD_LOCATION"/thumbs/ --exclude "$UPLOAD_LOCATION"/encoded-video/
borg prune --keep-weekly=4 --keep-monthly=3 "$BACKUP_PATH"
borg compact "$BACKUP_PATH"
