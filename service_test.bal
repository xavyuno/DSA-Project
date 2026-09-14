// A1-A4 - basic checks for the REST side
import ballerina/http;
import ballerina/test;

http:Client api = check new ("http://localhost:9090/api");

@test:Config {}
function testSeedData() {
    Asset? asset = getAsset("NUST-LIB-3DP-001");
    test:assertTrue(asset is Asset, "seed asset should exist");
}

@test:Config {}
function testFilterByInstitution() returns error? {
    Asset[] assets = check api->get("/assets?institution=NUST");
    test:assertTrue(assets.length() >= 2, "NUST filter should return seeded NUST assets");
    foreach Asset asset in assets {
        test:assertEquals(asset.institution, "NUST");
    }
}

@test:Config {}
function testOverdueDashboard() returns error? {
    Asset[] assets = check api->get("/overdue?asOf=2026-09-14");
    boolean foundPrinter = false;
    foreach Asset asset in assets {
        if asset.assetTag == "NUST-LIB-3DP-001" {
            foundPrinter = true;
        }
    }
    test:assertTrue(foundPrinter, "printer maintenance is overdue by 2026-09-14");
}

@test:Config {}
function testCreateAndDeleteAsset() returns error? {
    AssetPayload payload = {
        assetTag: "TEST-ASSET-001",
        name: "Temporary Test Asset",
        description: "created by the test",
        institution: "NUST",
        site: "Main Campus",
        status: "AVAILABLE",
        dateAcquired: "2026-08-01"
    };
    http:Response created = check api->post("/assets", payload);
    test:assertEquals(created.statusCode, 201);

    http:Response removed = check api->delete("/assets/TEST-ASSET-001");
    test:assertEquals(removed.statusCode, 200);
}

@test:Config {}
function testLoanRejectsUnavailableAsset() returns error? {
    AssetPayload payload = {
        assetTag: "TEST-LOAN-001",
        name: "Loan Test Laptop",
        description: "loan test",
        institution: "UNAM",
        site: "Main Campus",
        status: "UNDER_MAINTENANCE",
        dateAcquired: "2026-05-01"
    };
    _ = check api->post("/assets", payload);
    http:Response response = check api->post("/assets/TEST-LOAN-001/loan", {borrower: "student1", dueDate: "2026-09-20"});
    test:assertEquals(response.statusCode, 400);
    _ = check api->delete("/assets/TEST-LOAN-001");
}

@test:Config {}
function testScheduleAndWorkOrderHelpers() returns error? {
    Asset asset = {
        assetTag: "TEST-MAINT-001",
        name: "Maintenance Test Asset",
        description: "temporary test asset",
        institution: "NUST",
        site: "Main Campus",
        status: "AVAILABLE",
        dateAcquired: "2026-01-10"
    };
    test:assertTrue(addAsset(asset));

    Asset withSchedule = check addScheduleToAsset("TEST-MAINT-001", {
        scheduleId: "TEST-SCH-1",
        'type: "SERVICING",
        dueDate: "2026-09-01",
        description: "test service"
    });
    test:assertEquals(withSchedule.schedules.length(), 1);

    Asset withOrder = check openWorkOrder("TEST-MAINT-001", {
        orderId: "TEST-WO-1",
        status: "IN_PROGRESS",
        description: "screen fault"
    });
    test:assertEquals(withOrder.workOrders[0].status, "OPEN");

    Asset withTask = check addTaskToWorkOrder("TEST-MAINT-001", "TEST-WO-1", {
        taskId: "TEST-T1",
        description: "replace screen"
    });
    test:assertEquals(withTask.workOrders[0].tasks.length(), 1);

    Asset closed = check closeWorkOrder("TEST-MAINT-001", "TEST-WO-1");
    test:assertEquals(closed.workOrders[0].status, "CLOSED");
    test:assertTrue(deleteAsset("TEST-MAINT-001"));
}

@test:Config {}
function testUnknownRouteReturns404() returns error? {
    http:Response response = check api->get("/this-route-does-not-exist");
    test:assertEquals(response.statusCode, 404);
}
