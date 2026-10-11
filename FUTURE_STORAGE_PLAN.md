# Storage plan

**Docker mounts NFS before starting the application.**

**Why it matters:** Nextcloud and Immich would require TrueNAS storage to start. DNS, Caddy, and your other containers remain independent.

This changes **who manages the mount**, not where your files live. No changes have been made.

## How the mount works

Your current setup has two separate steps:

```text
Rasputin mounts TrueNAS through fstab
Docker binds a host directory into the container
```

Docker knows the host directory, but doesn't know that the directory must contain an NFS mount.

An NFS-backed Docker volume combines those steps:

```text
Docker mounts the TrueNAS export
Docker attaches that filesystem to the container
Docker starts the application
```

If the NFS mount fails, Docker cannot start that container. Docker doesn't substitute local storage.

Docker still uses Rasputin's Linux NFS client. No TrueNAS API integration or extra software inside the application container is required.

## What Immich's configuration would look like

This is an illustrative excerpt for `immich/docker-compose.yml`, **not a complete replacement**:

```yaml
services:
  immich_server:
    volumes:
      - type: volume
        source: immich_media
        target: /data
        volume:
          subpath: immich_library
          nocopy: true
      - /etc/localtime:/etc/localtime:ro

volumes:
  immich_media:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.125,nfsvers=4.2,rw,hard
      device: ":/mnt/Pool_1M/Immich"
```

The fields have specific jobs:

| Field | Purpose |
|---|---|
| `driver: local` | Uses Docker's built-in volume driver. The name doesn't mean the data must be local. |
| `type: nfs` | Mounts an NFS filesystem. |
| `addr` and `device` | Identify TrueNAS and your existing export. |
| `subpath: immich_library` | Exposes your existing library directory at `/data`. |
| `nocopy: true` | Prevents Docker from copying files from the container image into the volume. |
| `hard` | Retries filesystem operations if TrueNAS becomes unreachable. |

Your existing database, Redis, and machine-learning volumes stay unchanged.

Before using this configuration, we'd verify that your Docker and Compose versions support volume subpaths. The `immich_library` directory must already exist, as it does in your current setup.

## Nextcloud AIO needs a separate transition

AIO creates the actual Nextcloud container, so we can't configure its storage directly in the mastercontainer's `volumes` list.

AIO supports a pre-created volume named:

```text
nextcloud_aio_nextcloud_datadir
```

The proposed arrangement would be:

- Back that volume with your existing `/mnt/Pool_1M/Nextcloud/Datadir` NFS export.
- Configure AIO to use that volume.
- Keep `/mnt/ncdata` as the path inside Nextcloud.

**For an existing installation, don't change `NEXTCLOUD_DATADIR` on its own.** AIO warns against that. We'd follow its documented transition procedure and verify that the volume exposes the existing data.

No file copy should be necessary if the new volume points to exactly the same dataset. We still need a maintenance window to change the container's storage attachment.

## What happens when TrueNAS is unavailable?

| Situation | Behaviour |
|---|---|
| TrueNAS is unavailable during the initial mount | The affected container cannot start. Other containers remain independent. |
| TrueNAS disappears while the application runs | The `hard` NFS mount can block filesystem operations until TrueNAS returns. |
| TrueNAS returns after a failed container start | Recovery depends on Docker's startup and retry behaviour. We'd verify that separately. |

This prevents local-storage fallback. It doesn't make the application usable during a NAS outage.

## How I'd approach the change

I'd transition **Immich first**, because its storage is directly controlled by Compose. We'd preserve the existing export, directory layout, and permissions.

Then we'd handle Nextcloud AIO separately. The host's existing `fstab` mounts can remain during the transition, but the applications would no longer depend on them.

For more detail, see [Docker's NFS-volume documentation](https://docs.docker.com/engine/storage/volumes/#create-a-service-which-creates-an-nfs-volume) and [AIO's data-directory guidance](https://github.com/nextcloud/all-in-one#how-to-change-the-default-location-of-nextclouds-datadir).
