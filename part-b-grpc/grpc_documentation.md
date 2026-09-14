# gRPC rental system quick reference

Server address: `http://localhost:9190`

The service contract is `part-b-grpc/rental.proto`. Run `part-b-grpc/generate_stubs.sh` once before building the server/client so Ballerina can generate `rental_pb.bal` from the contract.

| RPC | Type | Behaviour |
| --- | --- | --- |
| `add_property` | Simple RPC | Registers a property and returns a generated property ID. |
| `create_users` | Client-side streaming | Receives several host/guest profiles and returns one count/confirmation. |
| `update_property` | Simple RPC | Updates price, status and description by property ID. |
| `remove_property` | Simple RPC | Removes the property and returns available properties in the removed property's region. |
| `list_available_properties` | Server-side streaming | Streams matching available properties one at a time. Supports location, price and property-type filters. |
| `search_property` | Simple RPC | Looks up one property ID and reports `Available` or `Not Available`. |
| `book_property` | Simple RPC | Validates guest/property/date input and stores a temporary request. |
| `confirm_booking` | Simple RPC | Re-checks overlapping dates, calculates nights and total cost, stores the confirmed booking and removes the temporary request. |

The server uses Ballerina maps for properties, users, temporary bookings and confirmed bookings. Critical map/counter updates are placed inside `lock` blocks.
