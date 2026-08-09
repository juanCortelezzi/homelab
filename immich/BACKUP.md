# Immich backups

Daily borg backup of the Immich library plus a postgres dump. The TrueNAS NFS
share is mounted at `/mnt/truenas/immich`. The Immich library is stored in
`immich_library`, and its borg backup repository is stored in `borgbackup`.

## Fresh setup (one command)

Prerequisites: `borg` installed, the TrueNAS NFS share configured in
`/etc/fstab` and mounted at `/mnt/truenas/immich`, and the Immich stack running
via docker compose. The stack and backup script create and use these directories
inside the mounted share:

- `immich_library`
- `immich_database`
- `immich_redis`
- `borgbackup`

```sh
./install-backup.sh
```

That installs and enables a systemd timer (`immich-backup.timer`) that runs
`backup.sh` daily at 03:30. `Persistent=true` means that if the Pi was off
past a scheduled run, exactly one catch-up backup fires on boot, not one per
missed day. The script auto-creates the borg repo on first run, so there is
nothing else to do.

## What the script does

1. Refuses to run unless `/mnt/truenas/immich` is a mounted filesystem
   (prevents backing up into an empty local directory).
2. Initializes the borg repo if it does not exist yet.
3. Dumps the postgres database into the library folder so it is included in
   the archive.
4. Creates a borg archive, excluding `thumbs/` and `encoded-video/`
   (regenerable data).
5. Prunes to 7 daily, 4 weekly, 3 monthly archives, then compacts.

## Useful commands

```sh
sudo systemctl start immich-backup.service       # run a backup now
journalctl -u immich-backup.service              # logs
systemctl list-timers immich-backup.timer        # next run
borg list /mnt/truenas/immich/borgbackup        # list archives
```

## Restore

```sh
cd /tmp && borg extract /mnt/truenas/immich/borgbackup::<archive-name>
```

Then follow https://immich.app/docs/administration/backup-and-restore
(restore the library folder, then feed `database_backup/immich-database.sql`
into a fresh postgres container before starting the server).

## Caveats

- The borg repo lives on the same TrueNAS box as the live library, so this
  protects against accidental deletion and database corruption, not against
  the NAS dying. Add ZFS snapshots and off-site replication on TrueNAS for
  that.
- Borg over NFS is slower and if the mount drops mid-run the repo can be
  left locked; fix with `borg break-lock /mnt/truenas/immich/borgbackup`.
