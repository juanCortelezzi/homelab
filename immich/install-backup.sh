#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sed "s|@SCRIPT@|$SCRIPT_DIR/backup.sh|" "$SCRIPT_DIR/immich-backup.service" |
	sudo tee /etc/systemd/system/immich-backup.service >/dev/null
sudo cp "$SCRIPT_DIR/immich-backup.timer" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now immich-backup.timer
systemctl list-timers immich-backup.timer --no-pager
