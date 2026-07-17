# RISC-V Minecraft Server Docker Image

Experimental `linux/riscv64` port of
[`itzg/docker-minecraft-server`](https://github.com/itzg/docker-minecraft-server).

This fork keeps the upstream Docker entrypoint structure and focuses on making
Minecraft Java Edition servers run on RISC-V boards. The first working targets
are Vanilla and Paper.

## Status

| Feature | Status | Notes |
| --- | --- | --- |
| `linux/riscv64` image build | Tested | Built on RevyOS/Debian trixie |
| Java runtime | Tested | `riscv64/eclipse-temurin:25-jre` |
| `TYPE=VANILLA` | Tested | Starts and persists `/data` |
| `TYPE=PAPER` | Tested | Downloads and starts Paper `26.1.2-69` |
| `ONLINE_MODE=false` | Tested | Useful for LAN/offline testing |
| UID/GID demotion | Tested | Minecraft process runs as uid/gid `1000` |
| RCON server | Partial | Minecraft RCON starts, `rcon-cli` is still a shim |
| Healthcheck | Partial | Uses a temporary RISC-V shim |
| Auto-pause/auto-stop | Not ready | Depends on missing helper tools |
| Forge/Fabric/modpacks | Not tested | Future work |

## Important RISC-V Runtime Note

Current RISC-V Docker setups may block the Java instruction-cache flush syscall.
Run the container with:

```yaml
security_opt:
  - seccomp=unconfined
```

Without that setting, Java can fail with:

```text
RISCV_FLUSH_ICACHE not available
Unable to synchronize I-cache
```

## Quick Start

Build the local image:

```bash
sudo ./build-riscv64-image.sh
```

Run with Docker Compose v1:

```bash
sudo docker-compose up -d
sudo docker-compose logs -f
```

Run with Docker Compose v2:

```bash
sudo docker compose up -d
sudo docker compose logs -f
```

The bundled compose file currently starts Paper:

```yaml
environment:
  EULA: "true"
  TYPE: "PAPER"
  VERSION: "LATEST"
  MEMORY: "2G"
  ONLINE_MODE: "false"
```

To use Vanilla instead:

```yaml
TYPE: "VANILLA"
```

## Docker Run

If Docker Compose is not installed:

```bash
sudo docker run -d --name mc-riscv \
  -p 25565:25565 \
  --security-opt seccomp=unconfined \
  -e EULA=TRUE \
  -e TYPE=PAPER \
  -e VERSION=LATEST \
  -e ONLINE_MODE=false \
  -e MEMORY=2G \
  -v "$PWD/data:/data" \
  riscv64-minecraft-server:local
```

Follow logs:

```bash
sudo docker logs -f mc-riscv
```

The server is ready when the log shows:

```text
Done (...)! For help, type "help"
```

## Configuration

This fork preserves the upstream environment-variable model where possible.
Common variables:

| Variable | Example | Meaning |
| --- | --- | --- |
| `EULA` | `TRUE` | Required to accept the Minecraft EULA |
| `TYPE` | `VANILLA`, `PAPER` | Server type |
| `VERSION` | `LATEST`, `26.1.2` | Minecraft version |
| `MEMORY` | `2G` | Initial and max heap |
| `ONLINE_MODE` | `true`, `false` | Mojang account authentication |
| `UID` / `GID` | `1000` | Runtime user and group |

`ONLINE_MODE=false` is convenient for LAN testing, but it disables username
authentication. Avoid exposing an offline-mode server directly to the public
internet.

## Data

Minecraft data is stored in `/data`.

With the included compose file, Docker stores it in the named volume:

```text
docker-minecraft-server-riscv_data
```

Stop the server without deleting data:

```bash
sudo docker-compose down
```

Delete the server data too:

```bash
sudo docker-compose down -v
```

## Upstream

This project is derived from
[`itzg/docker-minecraft-server`](https://github.com/itzg/docker-minecraft-server)
and keeps its Apache-2.0 license.

See [UPSTREAM.md](UPSTREAM.md) for the RISC-V patch boundary and current
differences from upstream.

## Releases

This repository currently focuses on source builds and local RISC-V validation.
Published multi-arch image and GitHub Release workflows are still on the
roadmap. Until then, build the image locally with `./build-riscv64-image.sh`.

## Contributing

RISC-V validation reports and small compatibility fixes are welcome. Please see
[CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request, especially if
the change affects upstream parity or helper-tool shims.

## Security

Do not expose an `ONLINE_MODE=false` server to the public internet. For security
reports about this RISC-V fork, see [SECURITY.md](SECURITY.md).

## License

This fork is distributed under the [Apache License 2.0](LICENSE), matching the
upstream project. Minecraft, Paper, Java runtimes, and downloaded third-party
server components remain subject to their own licenses and terms.

## Roadmap

- Replace temporary `files/riscv64-tools/` shims with real `linux/riscv64`
  builds of upstream helper tools
- Restore full RCON CLI and healthcheck behavior
- Validate plugins on Paper
- Validate Fabric with server-side optimization mods
- Validate Forge/NeoForge and modpack flows
- Add published image build workflow for `linux/riscv64`
