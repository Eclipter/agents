---
name: modify-darwin-nodes
description: Install packages or change configuration on the head node and Luna-managed nodes, either persistently in OS images (lchroot, luna osimage pack) or hot on running nodes (pdsh) on Darwin HPC cluster. Use when the user asks to install software, edit files in compute-image or storage-image or roll out a change to all nodes on Darwin HPC cluster.
---

# Modify nodes

## Connect to the head node

```sh
ssh root@darwin.bioeng.ru
```

## Choose the mode

- **Image (persistent)**: the change must survive reboots. Edit the image, pack it, back it up.
- **Hot (immediate, non-persistent)**: apply on running nodes via `pdsh`. Lost on reboot unless also done in the image.

Always ask the user (unless already stated):

1. If they want a change to be on the head node / compute nodes / storage nodes / all.
2. If they want a change to be permanent / visible now / both (ask unless the user answered "on the head node only" in the previous question).

## Images

| Image                    | Purpose                                                                    |
| ------------------------ | -------------------------------------------------------------------------- |
| `raw-compute-image-bak`  | Fresh Rocky 9.6 compute image after `ansible-playbook compute-default.yml` |
| `compute-image`          | Working image for compute nodes                                            |
| `full-compute-image-bak` | Backup of `compute-image`                                                  |
| `storage-image`          | Working image for storage nodes                                            |
| `full-storage-image-bak` | Backup of `storage-image`                                                  |

Image files live in `/trinity/images/<image>/`. Files changed there directly (without `lchroot`) still require `luna osimage pack`.

## Change the head node

Change the machine with hostname "darwin" (your are probably on it).

## Persistent change in an image

While this workflow is in progress, every user-visible message starts with the checklist below. Mark a step `[x]` when it is done and leave the rest `[ ]`. This is required output, not an internal note. Plan mode is not involved.

```
Task Progress:
- [ ] 1. Enter the image(s)
- [ ] 2. Apply the change(s)
- [ ] 3. Pack the image(s)
- [ ] 4. Reboot the nodes (if needed)
- [ ] 5. Refresh the old image backup(s)
```

1. Enter the image:

   ```bash
   lchroot compute-image
   ```

2. Install packages / edit files inside the chroot:

   ```bash
   dnf install -y nano
   ```

3. Exit and pack:

   ```bash
   exit
   luna osimage pack compute-image
   ```

4. Reboot the nodes (only if the change should be applied now and cannot be done with pdsh without reboot; ALWAYS ask the user before rebooting):

   ```bash
   luna control power reset \
       node01,node02,node03,node04,node05,node06,node07,node08,node09,node10,node11,node12,node13,node14
   ```

5. Refresh the backups (ALWAYS ask the user to check the changes and consent to refresh old backups):

   ```bash
   luna osimage remove full-compute-image-bak
   timeout 300 bash -c 'while [ -e /trinity/images/full-compute-image-bak ]; do sleep 1; done' &&
   luna osimage clone -o compute-image full-compute-image-bak
   ```

   For storage: same with `storage-image` / `full-storage-image-bak`.

## Hot change on running nodes

```bash
pdsh -a "dnf install -y nano"
```

or use this if the change should be scoped:

```bash
pdsh -w node01,node02 "dnf install -y nano"
```

alternatively:

```bash
pdsh -g compute-group "dnf install -y nano"
```

## Document the changes

Skip this step if the user chose to apply changes only on running nodes without keeping them after a reboot.

1. Add the changes to `/var/www/dokuwiki/data/pages/administration_guides/darwin_setup.txt`. Match the formatting and tone of the existing content exactly.
2. Update the backup script in `/var/www/dokuwiki/data/pages/administration_guides/darwin_management.txt` only for files created from scratch during the changes. A file that already existed and was only edited is not new. If there are no new files, leave the backup script unchanged. For each new file, choose one option: either document how to create it from scratch, or create it once and add its path to the backup script; never do both. If you add a whole new folder to the backup script, do not forget to unarchive it in a suitable place in the setup guide.

## Caveats

- `lchroot` and `luna osimage pack` run on the head node (darwin) as root.
- Exports are managed by trinityX playbooks; manual edits go to `/etc/exports.d/trinity.exports`.
