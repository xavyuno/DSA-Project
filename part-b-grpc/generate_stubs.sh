# B1 - generate Ballerina gRPC stubs from rental.proto
#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

command -v bal >/dev/null 2>&1 || {
  echo "Ballerina CLI not found. Install Swan Lake 2201.13.5 first." >&2
  exit 1
}

rm -f server/rental_pb.bal client/rental_pb.bal
bal grpc --input rental.proto --output server
cp server/rental_pb.bal client/rental_pb.bal

echo "Generated rental_pb.bal for server and client."
