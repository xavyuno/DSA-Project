// A1-A3 - REST routes joining the backend pieces together
// group credit note: the original repo already had the /api asset CRUD routes in this file.
// later changes kept those routes and added filtering, status/loan/booking, institutions, components, schedules,
// work orders/tasks and a bit more bad-request/not-found handling.
// add the original contributor's name here once we check the repo history, dont guess it from this zip.
import ballerina/http;

listener http:Listener apiListener = new (9090, { host: "0.0.0.0" });

@http:ServiceConfig {
    cors: {
        //the server the hmtl file is hosted on must be listed in allow origins to work
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}
service /api on apiListener {

    resource function get assets(string? institution = (), string? site = ()) returns Asset[] {
        return filterAssets(institution, site);
    }

    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        Asset? asset = getAsset(assetTag);
        if asset is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        return asset;
    }

    resource function post assets(@http:Payload AssetPayload payload)
            returns http:Created|http:Conflict|http:BadRequest {
        if payload.assetTag == "" || payload.name == "" || payload.institution == "" {
            return <http:BadRequest>{body: {message: "assetTag, name and institution are required"}};
        }
        if !validDate(payload.dateAcquired) {
            return <http:BadRequest>{body: {message: "dateAcquired must use YYYY-MM-DD"}};
        }
        Asset asset = assetFromPayload(payload);
        if !addAsset(asset) {
            return <http:Conflict>{body: {message: "assetTag already exists"}};
        }
        return <http:Created>{body: asset};
    }

    resource function put assets/[string assetTag](@http:Payload AssetPayload payload)
            returns Asset|http:NotFound|http:BadRequest {
        if assetTag != payload.assetTag {
            return <http:BadRequest>{body: {message: "assetTag in path and body must match"}};
        }
        if !validDate(payload.dateAcquired) {
            return <http:BadRequest>{body: {message: "dateAcquired must use YYYY-MM-DD"}};
        }
        Asset asset = assetFromPayload(payload);
        if !updateAsset(asset) {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        return asset;
    }

    resource function delete assets/[string assetTag]() returns http:Ok|http:NotFound {
        if !deleteAsset(assetTag) {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        return <http:Ok>{body: {message: "Asset removed"}};
    }

    resource function get assets/[string assetTag]/status() returns StatusView|http:NotFound {
        Asset? asset = getAsset(assetTag);
        if asset is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        return {assetTag: asset.assetTag, status: asset.status, schedules: asset.schedules.clone()};
    }

    resource function post assets/[string assetTag]/loan(@http:Payload LoanRequest request)
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = loanAsset(assetTag, request);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function post assets/[string assetTag]/book(@http:Payload BookingRequest request)
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = bookAsset(assetTag, request);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function get overdue(string? asOf = ()) returns Asset[]|http:BadRequest {
        string date = asOf is string ? asOf : todayIsoDate();
        Asset[]|error result = getOverdueAssets(date);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function get institutions() returns Institution[] {
        return getInstitutions();
    }

    resource function post institutions(@http:Payload InstitutionPayload payload)
            returns http:Created|http:Conflict|http:BadRequest {
        if payload.code == "" || payload.name == "" {
            return <http:BadRequest>{body: {message: "institution code and name are required"}};
        }
        Institution institution = {code: payload.code, name: payload.name, sites: payload.sites.clone()};
        if !addInstitution(institution) {
            return <http:Conflict>{body: {message: "institution already exists"}};
        }
        return <http:Created>{body: institution};
    }

    resource function delete institutions/[string code]() returns http:Ok|http:NotFound {
        if !deleteInstitution(code) {
            return <http:NotFound>{body: {message: "Institution not found"}};
        }
        return <http:Ok>{body: {message: "Institution removed"}};
    }

    resource function post assets/[string assetTag]/components(@http:Payload Component component)
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = addComponentToAsset(assetTag, component);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function delete assets/[string assetTag]/components/[string compId]()
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = removeComponentFromAsset(assetTag, compId);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function post assets/[string assetTag]/schedules(@http:Payload Schedule schedule)
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = addScheduleToAsset(assetTag, schedule);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function put assets/[string assetTag]/schedules/[string scheduleId](@http:Payload Schedule schedule)
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = updateScheduleOnAsset(assetTag, scheduleId, schedule);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function delete assets/[string assetTag]/schedules/[string scheduleId]()
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = removeScheduleFromAsset(assetTag, scheduleId);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function post assets/[string assetTag]/workorders(@http:Payload WorkOrder workOrder)
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = openWorkOrder(assetTag, workOrder);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function put assets/[string assetTag]/workorders/[string orderId](@http:Payload WorkOrder workOrder)
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = replaceWorkOrder(assetTag, orderId, workOrder);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function post assets/[string assetTag]/workorders/[string orderId]/close()
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = closeWorkOrder(assetTag, orderId);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function post assets/[string assetTag]/workorders/[string orderId]/tasks(@http:Payload SubTask task)
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = addTaskToWorkOrder(assetTag, orderId, task);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }

    resource function delete assets/[string assetTag]/workorders/[string orderId]/tasks/[string taskId]()
            returns Asset|http:NotFound|http:BadRequest {
        if getAsset(assetTag) is () {
            return <http:NotFound>{body: {message: "Asset not found"}};
        }
        Asset|error result = removeTaskFromWorkOrder(assetTag, orderId, taskId);
        if result is error {
            return <http:BadRequest>{body: {message: result.message()}};
        }
        return result;
    }
}
