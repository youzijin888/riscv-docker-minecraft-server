#!/bin/sh
set -eu

container="${CONTAINER_NAME:-mc-riscv-upstream}"

docker rm -f "$container"
