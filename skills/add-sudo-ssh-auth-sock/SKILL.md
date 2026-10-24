---
name: add-sudo-ssh-auth-sock
description: "Enable sudo authentication via a forwarded SSH agent, including Cursor, using a system wrapper independent of shell startup files."
---

# Add sudo SSH auth sock

Cursor sets `SSH_AUTH_SOCK` to a user-owned symlink in sticky `/tmp` and retargets it on reconnect. With `fs.protected_symlinks=1`, root cannot follow that link, so `pam_ssh_agent_auth` fails.

Install a root-owned executable wrapper at `/usr/local/bin/sudo`. It resolves the link as the invoking user, then executes the real sudo with the resolved path. Resolve it on every invocation so reconnects keep working; leave the parent shell's `SSH_AUTH_SOCK` unchanged.

Keep `fs.protected_symlinks` enabled and retain SSH-agent authentication rather than adding `NOPASSWD`.

## Steps

1. Install the `pam_ssh_agent_auth` module. Skip if it is already installed.

   Debian/Ubuntu:

   ```bash
   apt-get install -y libpam-ssh-agent-auth
   ```

   RHEL/Fedora:

   ```bash
   dnf install -y pam_ssh_agent_auth
   ```

2. Enable the module before the common auth include in `/etc/pam.d/sudo`, if it is not there yet. On RHEL-family systems the include line is `auth include system-auth`. The sed regex already handles both. `%h` makes the module trust the invoking user's own `~/.ssh/authorized_keys`; preserve an existing `file=` or authorized-keys command instead of replacing its key policy. Before the edit, copy the file to `/etc/pam.d/sudo.bak` if that backup does not exist yet. After the edit, verify the module was actually inserted before password authentication. If the auth stack differs from these patterns, adapt to the actual file. If the result looks wrong, restore from the backup.

   ```bash
   grep -q pam_ssh_agent_auth /etc/pam.d/sudo || {
       [ -f /etc/pam.d/sudo.bak ] || cp /etc/pam.d/sudo /etc/pam.d/sudo.bak
       sed -i \
           -E '0,/^(@include[[:space:]]+common-auth|auth[[:space:]]+include[[:space:]]+system-auth)/s||auth       sufficient   pam_ssh_agent_auth.so file=%h/.ssh/authorized_keys\n&|' \
           /etc/pam.d/sudo
   }
   grep pam_ssh_agent_auth /etc/pam.d/sudo
   ```

3. Add `Defaults env_keep += "SSH_AUTH_SOCK"` to `/etc/sudoers.d/ssh-auth-sock` with mode `0440`. If the directive already applies in `/etc/sudoers` or `/etc/sudoers.d/`, skip the step. Inspect an existing file before editing; preserve unrelated rules. Validate the snippet and full configuration with `visudo -cf` and restore the previous content if validation fails. This configures authentication; the user still needs sudo permission.

   ```bash
   cat > /etc/sudoers.d/ssh-auth-sock << 'EOF'
   Defaults env_keep += "SSH_AUTH_SOCK"
   EOF
   chown root:root /etc/sudoers.d/ssh-auth-sock
   chmod 0440 /etc/sudoers.d/ssh-auth-sock
   visudo -cf /etc/sudoers.d/ssh-auth-sock
   visudo -cf /etc/sudoers
   ```

4. Verify that `/usr/bin/sudo` is the real sudo executable and `/usr/bin/readlink` supports `-f`. Adapt the absolute paths below if the host differs; never locate sudo through `PATH` from inside its wrapper. Inspect `/usr/local/bin/sudo` first: skip an identical wrapper and preserve or adapt any unrelated existing implementation. Create the wrapper as root, owned by `root:root` with mode `0755`, without a setuid bit.

   ```bash
   cat > /usr/local/bin/sudo << 'EOF'
   #!/bin/sh
   if [ -L "${SSH_AUTH_SOCK:-}" ]; then
       SSH_AUTH_SOCK=$(/usr/bin/readlink -f -- "$SSH_AUTH_SOCK") || exit 1
       export SSH_AUTH_SOCK
   fi
   exec /usr/bin/sudo "$@"
   EOF
   chown root:root /usr/local/bin/sudo
   chmod 0755 /usr/local/bin/sudo
   ```

5. Verify `/usr/local/bin` precedes `/usr/bin` in the intended user's and Cursor agent's actual `PATH`. If it does not, fix the environment that launches that session. Explicit `/usr/bin/sudo` calls bypass the wrapper; report this limit. Do not replace the distribution's sudo binary.

## Verify

Verify as the intended non-root user, both in a fresh terminal and through the Cursor agent when it is part of the task. A root session or a cached sudo timestamp does not prove authentication works.

- `command -v sudo` resolves to `/usr/local/bin/sudo`.
- `sudo -k id` authenticates through the SSH agent and returns `uid=0(root)` without a password. Corroborate with the PAM authentication log. If the runner requires non-interactive input, use a supported invocation that still attempts PAM authentication; `sudo -n` alone can refuse before PAM runs.
- The parent shell's `SSH_AUTH_SOCK` remains the Cursor symlink, while `sudo printenv SSH_AUTH_SOCK` shows its resolved target.
- If agent execution cannot be invoked from the current tools, request a targeted check from that agent and distinguish it from tests performed through SSH.
