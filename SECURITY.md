# Security Policy

## Supported scope

This repository is experimental and currently validates local RISC-V builds for
Minecraft Java Edition servers. Security support focuses on:

- RISC-V-specific Dockerfile and startup changes
- temporary helper-tool shims
- bundled examples and default compose files
- documentation that could lead users to unsafe deployments

## Reporting a vulnerability

Please avoid public issues for sensitive reports. Email `youzijin8@gmail.com`
with:

- affected commit or configuration
- reproduction steps
- impact and suggested mitigation

## Deployment notes

- `ONLINE_MODE=false` disables Mojang account authentication. Use it only for
  controlled LAN or offline testing.
- Do not expose offline-mode servers directly to the public internet.
- Current RISC-V Java setups may require `seccomp=unconfined`; understand this
  trade-off before using the image beyond local testing.
