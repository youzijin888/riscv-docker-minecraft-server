# Contributing

Thanks for helping test and improve the RISC-V Minecraft server image.

## Project scope

This repository is a RISC-V port of
[`itzg/docker-minecraft-server`](https://github.com/itzg/docker-minecraft-server).
Keep changes focused on:

- `linux/riscv64` image builds
- RISC-V Java runtime behavior
- temporary helper-tool shims under `files/riscv64-tools/`
- docs and examples for running on RISC-V boards
- small upstream-parity fixes needed by Vanilla and Paper flows

For general Minecraft server image features that are not RISC-V specific,
consider contributing upstream first.

## Useful issue details

When reporting a bug, include:

- RISC-V board, VM, or cloud environment
- Linux distribution and kernel version
- Docker version and Compose version
- `TYPE`, `VERSION`, `MEMORY`, and whether `seccomp=unconfined` was used
- relevant container logs

Do not share private server IPs, access tokens, whitelist files, or world data.

## Pull requests

Before opening a pull request:

```bash
sudo ./build-riscv64-image.sh
sudo docker compose up -d
sudo docker compose logs -f
```

For script changes, also run the relevant test or startup path when possible.
Keep the RISC-V patch boundary documented in [UPSTREAM.md](UPSTREAM.md).
