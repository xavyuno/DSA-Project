from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[1]
errors = []

required_files = [
    "README.md",
    "part-a-rest-api/types.bal",
    "part-a-rest-api/database.bal",
    "part-a-rest-api/resources.bal",
    "part-a-rest-api/schedules.bal",
    "part-a-rest-api/service.bal",
    "part-a-rest-api/client/main.bal",
    "part-b-grpc/rental.proto",
    "part-b-grpc/server/server.bal",
    "part-b-grpc/client/client.bal",
    "docs/API_documentation.md",
    "docs/grpc_documentation.md",
]

for rel in required_files:
    if not (root / rel).is_file():
        errors.append(f"missing file: {rel}")

rest = (root / "part-a-rest-api/service.bal").read_text()
rest_needles = [
    "resource function get assets",
    "resource function post assets",
    "resource function put assets/",
    "resource function delete assets/",
    "/status()",
    "/loan(",
    "/book(",
    "resource function get overdue",
    "resource function get institutions",
    "/components",
    "/schedules",
    "/workorders",
    "/tasks",
]
for needle in rest_needles:
    if needle not in rest:
        errors.append(f"REST requirement not found: {needle}")

proto = (root / "part-b-grpc/rental.proto").read_text()
rpcs = {
    "add_property": "simple",
    "create_users": "client stream",
    "update_property": "simple",
    "remove_property": "simple",
    "list_available_properties": "server stream",
    "search_property": "simple",
    "book_property": "simple",
    "confirm_booking": "simple",
}
for name in rpcs:
    if not re.search(rf"\brpc\s+{re.escape(name)}\s*\(", proto):
        errors.append(f"missing RPC: {name}")
if not re.search(r"rpc\s+create_users\s*\(\s*stream\s+UserCreateInput", proto):
    errors.append("create_users is not client-side streaming")
if not re.search(r"rpc\s+list_available_properties\s*\([^)]*\)\s*returns\s*\(\s*stream\s+Property", proto):
    errors.append("list_available_properties is not server-side streaming")

server = (root / "part-b-grpc/server/server.bal").read_text()
for needle in ["tempBookings", "bookings", "rangesOverlap", "countNights", "totalCost"]:
    if needle not in server:
        errors.append(f"booking logic marker not found: {needle}")

# Quick delimiter check catches accidental file truncation/edit mistakes.
for path in root.rglob("*.bal"):
    text = path.read_text()
    for left, right in [("{", "}"), ("(", ")"), ("[", "]")]:
        if text.count(left) != text.count(right):
            errors.append(f"unbalanced {left}{right} in {path.relative_to(root)}")

if errors:
    print("CHECK FAILED")
    for item in errors:
        print(" -", item)
    sys.exit(1)

print("Static assignment check passed.")
print("Required files, REST operations, RPC names/streaming markers and booking logic are present.")
