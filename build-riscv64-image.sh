#!/bin/sh
set -eu

image="${IMAGE:-riscv64-minecraft-server:local}"

docker build -t "$image" .

echo "Built image: $image"
echo "Run with: docker compose up -d"
