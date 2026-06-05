#!/bin/sh
set -eu

container="${CONTAINER_NAME:-mc-riscv-upstream}"
image="${IMAGE:-riscv64-minecraft-server:local}"
data_dir="${DATA_DIR:-$(pwd)/examples/riscv64/data}"

mkdir -p "$data_dir"

if docker ps --format '{{.Names}}' | grep -qx "$container"; then
  echo "Container '$container' is already running."
  echo "Logs: ./examples/riscv64/logs.sh"
  exit 0
fi

if docker ps -a --format '{{.Names}}' | grep -qx "$container"; then
  echo "Removing stopped container '$container'."
  docker rm "$container" >/dev/null
fi

docker run -d \
  --name "$container" \
  -p "${SERVER_PORT:-25565}:25565" \
  --security-opt seccomp=unconfined \
  -e EULA="${EULA:-TRUE}" \
  -e TYPE="${TYPE:-VANILLA}" \
  -e VERSION="${VERSION:-LATEST}" \
  -e MEMORY="${MEMORY:-2G}" \
  -e ONLINE_MODE="${ONLINE_MODE:-false}" \
  -v "$data_dir:/data" \
  --restart unless-stopped \
  "$image"

echo "Started container: $container"
echo "Logs: ./examples/riscv64/logs.sh"
echo "Stop: ./examples/riscv64/stop.sh"
