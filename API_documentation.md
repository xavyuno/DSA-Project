# REST API quick reference

Base URL: `http://localhost:9090/api`

## Assets

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/assets` | List all assets. Optional query parameters: `institution`, `site`. |
| GET | `/assets/{assetTag}` | Get one asset. |
| POST | `/assets` | Create an asset. |
| PUT | `/assets/{assetTag}` | Replace/update an asset. |
| DELETE | `/assets/{assetTag}` | Remove an asset. |
| GET | `/assets/{assetTag}/status` | Show current status and schedules. |
| POST | `/assets/{assetTag}/loan` | Loan an available asset. |
| POST | `/assets/{assetTag}/book` | Add a booking after date/overlap checks. |
| GET | `/overdue` | List assets with overdue maintenance/servicing schedules. Optional `asOf=YYYY-MM-DD`. |

## Institutions

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/institutions` | List institutions. |
| POST | `/institutions` | Add an institution. |
| DELETE | `/institutions/{code}` | Remove an institution from the institution listing. |

## Components

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/assets/{assetTag}/components` | Add a component. |
| DELETE | `/assets/{assetTag}/components/{compId}` | Remove a component. |

## Schedules

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/assets/{assetTag}/schedules` | Add a schedule. |
| PUT | `/assets/{assetTag}/schedules/{scheduleId}` | Modify a schedule. |
| DELETE | `/assets/{assetTag}/schedules/{scheduleId}` | Remove a schedule. |

## Work orders and tasks

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/assets/{assetTag}/workorders` | Open a work order. The service forces the initial status to `OPEN`. |
| PUT | `/assets/{assetTag}/workorders/{orderId}` | Update a work order. |
| POST | `/assets/{assetTag}/workorders/{orderId}/close` | Close a work order. |
| POST | `/assets/{assetTag}/workorders/{orderId}/tasks` | Add a sub-task. |
| DELETE | `/assets/{assetTag}/workorders/{orderId}/tasks/{taskId}` | Remove a sub-task. |

Dates use `YYYY-MM-DD`. The service returns `404` for unknown primary resources, `409` for duplicate top-level keys, and `400` for invalid payloads/state transitions.
