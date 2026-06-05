#!/bin/sh
set -eu

container="${CONTAINER_NAME:-mc-riscv-upstream}"

exec docker logs -f "$container"
