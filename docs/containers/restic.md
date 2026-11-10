# Restic

Restic (`backup/`) backs up Vaultwarden, Memos, Homarr and the Immich photos to a Synology NAS over SFTP. Backups are encrypted and deduplicated, so each run only sends what changed.

The timer runs on Monday, Wednesday and Friday at 10:00 (Amsterdam time), when the NAS is on. Each run:

1. Checks that the NAS is reachable. If it isn't, the run fails without stopping anything and retries every 30 minutes, up to 6 times.
2. Stops Vaultwarden, Memos and Homarr, so their SQLite databases aren't copied mid-write. That means a few seconds to minutes of downtime.
3. Runs `restic backup`, then `restic forget --prune`, which keeps 7 daily, 4 weekly and 6 monthly snapshots.
4. Starts the three apps again, even if the backup failed.

Syncthing is not a replacement for this: it syncs deletions and corruption to every device, and has no history.

## What gets backed up

| App | Source | Notes |
| --- | --- | --- |
| Vaultwarden | `vaultwarden-data` volume | Database, attachments, sends and `rsa_key*`. |
| Memos | `memos-data` volume | SQLite database and uploads. |
| Homarr | `homarr-appdata` volume | Also keep the `homarr-encryption-key` secret somewhere safe. Without it, a restore can't decrypt the integrations. |
| Immich | `/var/mnt/photos` | Originals, profile pictures and database dumps. `thumbs/` and `encoded-video/` are skipped, as Immich can regenerate them. |

Immich's Postgres volume isn't copied directly, as a copy of a running database may not be usable. Immich writes its own database dumps to `/var/mnt/photos/backups` instead. Check that they are enabled in Administration → Settings → Backup Settings. The default is daily at 02:00, keeping 14 dumps.

Not backed up: Valkey (cache), the Immich model cache, and Immich's Postgres volume (covered by the dumps).

## Prepare the Synology

In DSM:

1. Control Panel → File Services → FTP → SFTP: enable SFTP (port 22).
2. Control Panel → User & Group → Advanced → User Home: enable the user home service. DSM needs this for SSH key login.
3. Control Panel → Shared Folder: create a shared folder `backup`. If the volume is Btrfs, tick "Enable data checksum".
4. Control Panel → User & Group: create a user `restic` with read/write access to `backup` only, and no access to other shares or apps.

SFTP paths start at the shared folder name, so the repository is `sftp:restic@nas.home.example.com:/backup/restic` (not `/volume1/backup`).

Optional but recommended: in Snapshot Replication, take daily snapshots of `backup` and keep them for 30 days. The server can delete files in the repository over SFTP, so if it is ever compromised, the backups could be wiped. NAS snapshots protect against that.

## Create the SSH key and secrets

On the server, create an SSH key for the backup only:

```bash
$ ssh-keygen -t ed25519 -N '' -C restic-backup -f ~/restic_key
```

Add `~/restic_key.pub` to the `restic` user on the NAS. DSM only allows SSH login for admins, so enable SSH temporarily (Control Panel → Terminal & SNMP → Enable SSH service) and log in with your admin account:

```bash
$ scp ~/restic_key.pub admin@nas.home.example.com:/tmp/
$ ssh admin@nas.home.example.com
$ sudo mkdir -p /var/services/homes/restic/.ssh
$ sudo mv /tmp/restic_key.pub /var/services/homes/restic/.ssh/authorized_keys
$ sudo chown -R restic:users /var/services/homes/restic
$ sudo chmod 755 /var/services/homes/restic
$ sudo chmod 700 /var/services/homes/restic/.ssh
$ sudo chmod 600 /var/services/homes/restic/.ssh/authorized_keys
```

The permissions matter: if they are looser, DSM ignores the key and asks for a password. Disable the SSH service again afterwards. SFTP keeps working.

Back on the server, test the key. You should get an `sftp>` prompt, and `ls` should show `backup`:

```bash
$ sftp -i ~/restic_key restic@nas.home.example.com
```

Store the key, the NAS host key and a new repository password as Podman secrets, then remove the key files:

```bash
$ podman secret create restic-ssh-key ~/restic_key
$ ssh-keyscan -t ed25519 nas.home.example.com | podman secret create restic-known-hosts -
$ openssl rand -base64 32 | tr -d "\n" | podman secret create restic-password -
$ rm ~/restic_key ~/restic_key.pub
```

Save the repository password outside the server, e.g. on paper or in a password manager that isn't this Vaultwarden. Without it, the backups can't be read. Show it with:

```bash
$ podman secret inspect --showsecret --format '{{.SecretData}}' restic-password
```

## Install

Replace `nas.home.example.com` in `restic-backup.container` (two places). If you don't run all three apps, remove the missing ones from the `systemctl` lines, otherwise the run fails. Then copy the files. Quadlet doesn't handle timers, so the timer goes into the regular systemd directory:

```bash
$ mkdir -p ~/.config/containers/systemd ~/.config/systemd/user
$ cp -r templates/containers/backup ~/.config/containers/systemd/
$ mv ~/.config/containers/systemd/backup/restic-backup.timer ~/.config/systemd/user/
$ systemctl --user daemon-reload
```

Add a shell helper for manual restic commands. It uses the same secrets and repository as the service, and `RESTIC_MOUNT` optionally mounts a volume or directory for restores. Put it in `~/.bashrc` to keep it:

```bash
restic-nas() {
  podman run --rm -it --security-opt label=disable \
    --hostname restic-backup \
    --secret restic-password,type=env,target=RESTIC_PASSWORD \
    --secret restic-ssh-key,type=mount,target=/root/.ssh/id_ed25519,mode=0600 \
    --secret restic-known-hosts,type=mount,target=/root/.ssh/known_hosts,mode=0644 \
    -e RESTIC_REPOSITORY=sftp:restic@nas.home.example.com:/backup/restic \
    -v restic-cache:/root/.cache/restic \
    ${RESTIC_MOUNT:+-v "$RESTIC_MOUNT"} \
    docker.io/restic/restic:latest "$@"
}
```

Create the repository on the NAS (once):

```bash
$ restic-nas init
```

Run the first backup by hand while the NAS is on, and follow it. With a large photo library this can take hours. Later runs are much faster:

```bash
$ systemctl --user start restic-backup.service
$ journalctl --user -fu restic-backup.service
```

Then enable the timer:

```bash
$ systemctl --user enable --now restic-backup.timer
$ systemctl --user list-timers restic-backup.timer
```

## Check backups

List snapshots:

```bash
$ restic-nas snapshots
```

Verify the repository now and then, e.g. once a month. `--read-data-subset` also reads part of the actual data, which catches disk errors on the NAS:

```bash
$ restic-nas check --read-data-subset=5%
```

See the last run, or why it failed:

```bash
$ systemctl --user status restic-backup.service
$ journalctl --user -u restic-backup.service -n 100
```

## Restore

Snapshots contain everything under `/source`, e.g. `/source/memos`. Restore one app at a time into its volume. Stop the app first, then restore with `--delete`, so files that weren't in the snapshot are removed. This example restores Memos from the latest snapshot:

```bash
$ systemctl --user stop memos.service
$ RESTIC_MOUNT=memos-data:/target restic-nas restore latest:/source/memos --target /target --delete
$ systemctl --user start memos.service
```

Use a snapshot ID from `restic-nas snapshots` instead of `latest` to go back further. Vaultwarden (`vaultwarden-data`) and Homarr (`homarr-appdata`) work the same way. Homarr needs the same `homarr-encryption-key` secret as before.

To get back a single file, restore into a directory instead and copy what you need:

```bash
$ mkdir ~/restore
$ RESTIC_MOUNT=$HOME/restore:/target restic-nas restore latest --target /target --include /source/memos
```

For Immich, restore the photos into `/var/mnt/photos` the same way, with `latest:/source/photos` and `RESTIC_MOUNT=/var/mnt/photos:/target`, while the Immich pod is stopped. Then restore the database from the newest dump in `/var/mnt/photos/backups`, following the [Immich backup and restore docs](https://docs.immich.app/administration/backup-and-restore).

Test a restore once after setting this up, e.g. Memos into `~/restore`. A backup you have never restored from isn't proven to work.

## Offsite copy

The NAS is in the same place as the server, so a fire or theft takes out both. For an offsite copy, use Hyper Backup on the Synology to push the `backup` share to Synology C2 or B2. The data is already encrypted by restic.
