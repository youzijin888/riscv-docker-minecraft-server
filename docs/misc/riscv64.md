# RISC-V Notes

This fork targets `linux/riscv64` and defaults to
`riscv64/eclipse-temurin:25-jre`.

Current RISC-V Docker setups may block the Java instruction-cache flush syscall.
Run the container with:

```yaml
security_opt:
  - seccomp=unconfined
```

The initial supported server type is:

```yaml
environment:
  EULA: "TRUE"
  TYPE: "VANILLA"
  VERSION: "LATEST"
```

The upstream helper tools are temporarily shimmed while RISC-V native builds are
prepared. Advanced operations such as RCON CLI usage, auto-pause, and full query
health checks should be treated as incomplete in this bootstrap image.
