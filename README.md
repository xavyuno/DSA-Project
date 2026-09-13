# DSA612S Assignment 1

This repo contains both parts of assignment 1.

part-a-rest-api is the REST library/resource system from question 1.
part-b-grpc is the rental accommodation system from question 2.
docs just has some notes so we dont have to keep checking the assignment PDF for every endpoint/function.

<!-- group note(for ernst in particular): add the final member names + student numbers here before submission. also check that everyone has at least one contribution in the repo. -->

## what changed

When I compared the old repo with the assignment, A1 already had a decent start. The asset records, table using assetTag and basic CRUD were there.

The stuff that was still missing was mostly A2, A3 and A4:

- institution and campus filtering
- overdue maintenance checks
- institution add/remove
- component and schedule management
- work orders and their smaller tasks
- the REST client for loaning, booking, views and schedules

For part B the proto file was already mostly there, but the actual server/client side still needed most of the work. I added the property and user state, the property operations, client/server streaming parts, temporary booking cart, date checks, overlap checks and the final price calculation.

I kept the code pretty straightforward and close to the type of examples we did in the tutorials. no extra framework stuff or anything fancy just for the sake of it.

If we need the full before/after notes they are in `docs/assignment-gap-review.md`.


## credit for the stuff that was already in the repo

just noting this properly because some of the files were not new files and I dont want the cleanup to make it look like somebody else's work disappeared.

The downloaded repo copy doesnt have the `.git` history inside it, so I cant safely put member names next to each file from the zip alone. We should check github history/blame and replace the "original group contributor" wording in the file comments with the actual names before the final push.

`types.bal` was already there. The original group work had the main Asset model plus Component, Schedule, SubTask, WorkOrder and AssetPayload. The later fix was mostly adding the missing OCCUPIED status, proper schedule types, institution/loan/booking records and the task done flag.

`database.bal` was also already there and had the asset table plus the basic get/add/update/remove functions. That part belongs to the original contributor. The later work added institutions, filtering, extra sample records and the overdue/date helper functions.

`service.bal` already had the REST asset CRUD endpoints. Those were kept as the base. The later update added the assignment endpoints that were missing around filters, loan/booking, schedules/components, institutions, work orders/tasks and a few more error cases.

`rental.proto` was mostly done already, actually. It already had the rental messages and all 8 RPC operations, including client-side `create_users` streaming and server-side `list_available_properties` streaming. The later changes were mostly tidying it so the server/client match it. I also kept the original `User` message and `host_region` field instead of throwing those away.

The original repo also had the Ballerina version/package setup and `.devcontainer.json`. The devcontainer file is carried over unchanged. `Dependencies.toml` wasnt copied because Ballerina generated it for the old single-package layout, so it should be regenerated after the new split is built on the VM.

so basically A1 and B1 both had real group work in them already. A2/A3/A4 and the actual B2/B3/B4 implementations were the big missing areas we filled in later.

## where the subtasks are

A1
`part-a-rest-api/types.bal`
`part-a-rest-api/database.bal`
`part-a-rest-api/service.bal`
`part-a-rest-api/Ballerina.toml`

This is the base of the REST side. Data models, asset/institution storage and the main CRUD setup.

A2
`part-a-rest-api/database.bal`
`part-a-rest-api/resources.bal`
`part-a-rest-api/service.bal`

This is the filtering/query side: all assets, institution/site filters, overdue items, status checks and error handling.

A3
`part-a-rest-api/schedules.bal`
`part-a-rest-api/service.bal`

This has components, schedules, work orders and work-order tasks.

A4
`part-a-rest-api/client/main.bal`
`part-a-rest-api/client/Ballerina.toml`

This is the REST client menu for loan/book, global view, campus view, overdue view and schedule changes.

B1
`part-b-grpc/rental.proto`
`part-b-grpc/generate_stubs.sh`

The protobuf contract and the streaming definitions are here.

B2
`part-b-grpc/server/server.bal`

Main gRPC server logic for users and properties: add, update, remove, search and list available properties.

B3
`part-b-grpc/server/server.bal`
`part-b-grpc/server/tests/server_test.bal`

The booking side is in the same server file because it uses the same property state. This is the temp cart, dates, overlap check, nights/price and booking confirmation.

B4
`part-b-grpc/client/client.bal`
`part-b-grpc/client/Ballerina.toml`

The gRPC client. It runs through the operations and handles the streaming parts too.

There is some overlap between files, mainly service.bal and server.bal. thats normal because those files connect the different subtasks together.

## running part A

From `part-a-rest-api`:

```bash
bal build
bal test
bal run
```

The REST service uses port 9090 and the base path is `/api`.

Then open another terminal:

```bash
cd part-a-rest-api/client
bal run
```

The client has the stuff the assignment asks us to demonstrate: loan/book, all assets, campus filtering, overdue view and schedule management.

## running part B

From `part-b-grpc` first generate the grpc code:

```bash
chmod +x generate_stubs.sh
./generate_stubs.sh
```

Then build/test it:

```bash
bal build server
bal test server
bal build client
```

Start the server:

```bash
bal run server
```

and in another terminal:

```bash
bal run client
```

The client creates users through client-side streaming, does the property operations, reads the available-property stream, then books and confirms a property.

<!-- note for us: after we generate rental_pb.bal on the VM, check the final folder properly before pushing. I think keeping the generated stub in the repo will make the lecturer's build easier. -->

## upload/commit order

This isnt a strict rule, its just the order that makes the repo easier to follow if we are doing separate commits(this is after we decide what to use and/or mesh).

1. `README.md` and `.gitignore`
2. A1 files: `Ballerina.toml`, `types.bal`, `database.bal`
3. A2 files: `resources.bal` and `service.bal`
4. A3: `schedules.bal`
5. A4: `part-a-rest-api/client/` and then the REST tests
6. B1: `rental.proto` and `generate_stubs.sh`
7. B2/B3: `part-b-grpc/server/`
8. B4: `part-b-grpc/client/`
9. docs last

If we are just using normal git(which i am) we can add the folders together, this order is mostly useful if we want clean commits per section/person.

## before submission

The project files are currently set to Ballerina Swan Lake `2201.13.5`.

Dont commit `target/` folders.

The repo has been checked for the expected files and structure, but we still need to do the proper Ballerina compile/test on the Linux VM(mine-Alexander). Tomorrow we should run both servers, both clients, try the main good cases and a few bad inputs too. If Ballerina complains about any version-specific syntax we fix that before the final push.
