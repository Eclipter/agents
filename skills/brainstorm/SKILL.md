---
name: brainstorm
description: "Use when the user describes their case and asks to explore solutions or compare the
  viable alternatives."
---

# Brainstorm

Find the distinct ways to solve the user's problem. Keep the final choice with
the user.

## Workflow

1. State "• The goal I understood •" under that top-level heading.
2. List "• The hard constraints I understood •" under that top-level heading (use list).
3. List "• The soft constraints I understood •" under that top-level heading (use list).
4. Ask the user if your understanding is correct. Don't continue before the user answers.
5. Look for all distinct, plausible approaches. Check each approach against every hard
   constraint.
6. Present the results under "• Viable options •" and "• Omitted options •" top-level headings.
   - **Viable options.** Include only approaches that satisfy every hard
     constraint. Show a table which includes only differences between solutions, explain them at both the high level and the low level (separate by "|"). If only one qualifies, explain it on its
     own. If none qualify, say so.
   - **Omitted options.** Give each remaining approach one line with its name
     and the specific constraints it fails. If a constraint is unverified,
     name what needs checking. Keep rankings and trade-offs out of this list.

## Example

```markdown
# • The goal I understood •

You want to run remote Codex agents across multiple projects.

# • The hard constraints I understood •

- You can reach and control agents from a mobile device while your laptop is offline.
- No homelab.
- You can open any project in VS Code or Cursor.

# • The soft constraints I understood •

- Maximize isolation between projects and the host.
- Keep monthly hosting costs low.

# • Viable options •

| | 1 VPS, Linux user per project | 1 VPS, dev container per project | 1 VPS, gVisor container per project | 1 bare-metal or nested-KVM host, microVM per project | VPS per project | Managed cloud sandboxes or devboxes |
| --- | --- | --- | --- | --- | --- | --- |
| Isolation | Weakest host boundary \| Codex wraps commands in `bubblewrap` and `seccomp`, and `0700` home directories protect other users' SSH keys, yet all projects share one kernel and network stack | Process and filesystem boundary \| namespaces, cgroups, dropped capabilities, and `seccomp` isolate each project, yet a host kernel exploit or mounted host `docker.sock` compromises the whole VPS | User-space kernel boundary \| `runsc` intercepts syscalls in user space via `systrap` without KVM and blocks most host kernel exploits at a 5% to 15% syscall I/O cost | Hardware microVM boundary \| Docker Sandboxes or Firecracker gives each project its own guest kernel via `/dev/kvm` on one shared host and contains kernel panics and exploits within one project | Cloud VM boundary \| the provider's hypervisor gives each project its own kernel, disk, and IP, so a full compromise stays inside one project | Provider-managed VM or microVM boundary \| Docker Cloud Sandboxes and GitHub Codespaces run each workspace in a separate cloud VM or microVM with zero shared host state |
| Cost | Lowest \| one cheap VPS on any provider pools burst CPU and RAM across projects with zero container or guest OS overhead when idle | Low \| one cheap VPS on any provider pools burst CPU and RAM and adds only Docker Engine plus small per-container process overhead | Low to moderate \| one VPS on any provider pools burst CPU and RAM, while each running sandbox adds a Go Sentry process and extra memory | Moderate \| pools burst CPU and RAM on one server, though `/dev/kvm` requires bare metal around $15 to $50 per month on Hetzner or Scaleway or a nested-KVM VPS on DigitalOcean, GCP, or Azure, and each microVM reserves guest kernel RAM | High at project scale \| you pay for a separate VPS per project even when idle, and every VPS must be sized for peak builds on its own | Usage-billed \| paused workspaces bill $0 for compute and charge only storage, while active per-minute compute costs several times more than raw VPS capacity during long agent runs |
| Background persistence | Always on \| `systemd`, `tmux`, or Codex `app-server` keeps running until you stop it | Always on \| containers keep running on your VPS with no platform session cap | Always on \| gVisor containers keep running on your VPS with no platform session cap | Always on \| microVMs keep running on your host until you stop or delete them | Always on \| each VPS keeps running with no platform session cap | Capped by TTL and idle timers \| Docker Cloud Sandboxes expire in 1 to 24 hours unless you enable auto-restart or renew via SDK, and GitHub Codespaces stop after 30 to 240 minutes of inactivity or 12 hours max unless you ping the start API |
| IDE workflow | Direct SSH \| VS Code and Cursor connect straight over Remote-SSH with no container attach step | Container attach \| requires `devcontainer.json` or container `sshd`, adds attach latency, and Dev Containers support in Cursor is rougher than plain Remote-SSH | Container attach with slower file I/O \| uses the same container attach or `sshd` setup, and heavy file watchers or builds run slower through user-space syscall interception | SSH proxy or guest SSH \| `sbx` mounts the host workspace via filesystem passthrough and exposes `.sbx` SSH over `ProxyJump`, or Firecracker guests run `sshd` | Direct SSH per host \| VS Code and Cursor connect over Remote-SSH with no container layer, though you manage SSH keys and OS updates across every VPS | Managed SSH or CLI proxy \| Docker Cloud Sandboxes accept SSH keys on port 2222, while GitHub Codespaces open in VS Code via the Codespaces extension and need `gh codespace ssh --config` for Cursor |
| Toolchain and ports | Shared OS state \| global `apt` packages and `localhost` ports collide unless you configure ports and local toolchains per project | Isolated per project \| each container gets its own root filesystem, language versions, and network namespace | Isolated per project \| each sandbox gets its own root filesystem, language versions, and virtualized network stack | Independent guest OS \| each microVM gets its own kernel, root filesystem, and network stack | Independent full VM \| each project owns a complete Linux OS, port range, and init system | Independent cloud workspace \| each sandbox or codespace gets its own root filesystem, ports, and image or `devcontainer.json` setup |
| Docker builds by agents | Native, breaks user isolation \| adding a project user to the host `docker` group grants root equivalence on the shared VPS | Safe only with Sysbox or rootless DinD \| mounting host `docker.sock` grants host root, whereas `sysbox-runc` runs an isolated inner `dockerd` without KVM | Supported with extra flags \| inner `dockerd` runs inside `runsc` without host privileges if you set `--net-raw` and `--allow-packet-socket-write`, mount `tmpfs` on `/var/lib/docker`, and pass `--iptables=false` | Native and isolated \| each microVM runs its own private Docker daemon behind the hypervisor boundary with no host socket exposure | Native and isolated \| each agent uses its own VPS Docker daemon at full speed without risking other projects | Supported per template \| Docker Cloud Sandboxes and GitHub Codespaces run an isolated inner Docker daemon if you pick a Docker-enabled kit or add the `docker-in-docker` devcontainer feature |

# • Omitted options •

- Agents on your laptop over Tailscale. Fails staying reachable from a mobile device while your laptop is offline.
- Home server, Mac mini, or NAS over Tailscale. Fails the no-homelab constraint.
- Built-in OpenAI Codex cloud environments. Does not let VS Code or Cursor open the remote workspace in an IDE window.
- Ephemeral sandbox SDKs such as Modal Sandboxes or E2B without a separate control server. You cannot spawn or wake sandboxes from a mobile device while your laptop is offline unless you host an external control plane.
- Serverless containers such as Cloud Run or AWS Fargate. Do not accept inbound Remote-SSH connections from VS Code or Cursor without custom reverse-tunnel plumbing.
```
