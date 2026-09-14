# assignment 1 file map

Just putting this here so we can quickly see which files belong to which section without digging through the whole repo.

small credit note: A1 and B1 were not blank when we started. `types.bal`, `database.bal`, `service.bal` and `rental.proto` already had group work in them. I left comments at the top of those files saying what was already there vs what got added later. The zip copy doesnt tell me the exact member names, so we need to grab those from github history before submitting.

A1 - API/database foundation

- `part-a-rest-api/types.bal`
- `part-a-rest-api/database.bal`
- `part-a-rest-api/service.bal`
- `part-a-rest-api/Ballerina.toml`

Mostly the data models, table setup, institution storage and CRUD base.

A2 - filters and queries

- `part-a-rest-api/database.bal`
- `part-a-rest-api/resources.bal`
- `part-a-rest-api/service.bal`

All assets, institution/site filtering, overdue maintenance, status/booking checks and API error handling.

A3 - schedules and work orders

- `part-a-rest-api/schedules.bal`
- `part-a-rest-api/service.bal`

Components, schedules, work orders and the smaller work-order tasks.

A4 - REST client

- `part-a-rest-api/client/main.bal`
- `part-a-rest-api/client/Ballerina.toml`

The command line client for loan/book, global view, campus view, overdue dashboard and schedule management.

B1 - protobuf contract

- `part-b-grpc/rental.proto`
- `part-b-grpc/generate_stubs.sh`

The gRPC contract plus the client-side/server-side streaming definitions.

B2 - server core

- `part-b-grpc/server/server.bal`

Users/properties state and add, update, remove, search + available property listing.

B3 - booking logic

- `part-b-grpc/server/server.bal`
- `part-b-grpc/server/tests/server_test.bal`

Temporary booking request, date validation, overlap checking, number of nights, cost calculation and confirm booking.

B4 - gRPC client

- `part-b-grpc/client/client.bal`
- `part-b-grpc/client/Ballerina.toml`

Client calls and the demo flow for all the RPCs/streaming.

A few files show up under more than one label. Thats intentional, mainly the main REST service and gRPC server because they connect the subtasks together.
