# Upstream Alignment

This repository is a RISC-V port of
[`itzg/docker-minecraft-server`](https://github.com/itzg/docker-minecraft-server).

The upstream project is licensed under Apache-2.0. Keep `LICENSE` intact and
preserve this attribution when publishing derived images or source code.

## Port Strategy

The goal is to keep the upstream structure and behavior as much as possible,
while carrying a small RISC-V patch set.

Initial tested scope:

- Build on `linux/riscv64`
- Use `riscv64/eclipse-temurin:25-jre`
- Support the vanilla server path: `TYPE=VANILLA`
- Support the Paper server path: `TYPE=PAPER`
- Keep `/data`, `EULA`, `VERSION`, `MEMORY`, UID/GID handling, and
  `server.properties` generation from upstream
- Require `seccomp=unconfined` at runtime for current RISC-V Java behavior

Deferred upstream tools:

- `mc-server-runner`
- `mc-monitor`
- `rcon-cli`
- `restify`
- patched `knockd`

These tools are currently replaced with conservative shims under
`files/riscv64-tools/`. Vanilla and Paper can run, but advanced operational
features that require the real tools are intentionally unavailable or reduced.

## RISC-V Patch Set

- `Dockerfile`
  - Defaults to `riscv64/eclipse-temurin:25-jre`
  - Avoids BuildKit-only `RUN --mount` and heredoc syntax for easier local
    builds on RISC-V boards
  - Installs `gosu` from the Ubuntu RISC-V repository instead of copying a
    prebuilt image binary
  - Installs temporary shims for missing RISC-V helper tools
- `build/ubuntu/install-packages.sh`
  - Adds `gosu` and `openssl`
  - Skips patched `knockd` by default and installs an explicit unavailable stub
- `docker-compose.yml`
  - Uses the local RISC-V image name
  - Adds `seccomp=unconfined`

## Next Upstream Parity Work

1. Build or publish real `linux/riscv64` releases for the upstream Go tools.
2. Replace `files/riscv64-tools/` shims with real binaries.
3. Re-enable full healthcheck, RCON, auto-pause, and auto-stop behavior.
4. Validate plugins on `TYPE=PAPER`.
5. Validate Forge/Fabric/NeoForge and modpack flows after the vanilla and Paper
   paths are stable.
