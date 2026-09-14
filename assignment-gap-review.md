# Assignment 1 gap review

This is a comparison of the original repository against the task split in `DSA_Subtasks.pdf` and the marking requirements in Assignment 1.

## Question 1 - REST API

| Subtask | Original repository state | Completed in this version |
| --- | --- | --- |
| A1 - API and database foundation | Partly present. `types.bal`, `database.bal` and basic asset CRUD existed. The status model did not include `OCCUPIED`, institutions were not stored, and there were only basic asset operations. | Completed data models, asset table keyed by `assetTag`, institution table, seed data, CRUD and validation. |
| A2 - filtering and queries | Missing. No institution/site filters and no overdue-maintenance query. Error handling only covered the basic CRUD routes. | Added institution/site filtering, global view, overdue maintenance lookup, status/schedule view and typed HTTP error responses. |
| A3 - schedules and work orders | Missing. Components, schedules, work orders and tasks were only fields in the record; there were no management operations. | Added add/remove components, add/update/remove schedules, open/update/close work orders and add/remove work-order tasks. |
| A4 - client implementation | Missing. The `rest-api` subfolder was still the default greeting sample and did not act as an assignment client. | Added a separate Ballerina CLI client for loaning, booking, global view, campus view, overdue dashboard and schedule management. |

## Question 2 - gRPC rental system

| Subtask | Original repository state | Completed in this version |
| --- | --- | --- |
| B1 - Protocol Buffer contract | Mostly present. `rental.proto` already listed all required operations and both streaming types. | Cleaned the contract, kept every required RPC and made the request/response messages consistent with the implementation. |
| B2 - server data and core logic | Missing. There was no Ballerina gRPC server. | Added in-memory maps, property/user models and add/update/remove/search/list operations. |
| B3 - booking logic | Missing. | Added temporary booking cart, date validation, overlap checking, number-of-nights calculation, total-price calculation, confirmation and cart cleanup. |
| B4 - client implementation | Missing. | Added a Ballerina gRPC client that invokes every required operation, including client streaming for users and server streaming for available properties. |

## Repository-level issues found

The original `readme.md` was empty, there was a duplicate starter `rest-api` project containing a greeting example, documentation was missing, and the two assignment questions were mixed in one root package. The completed version separates the REST and gRPC work and includes run/test notes.
