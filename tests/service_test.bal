import ballerina/http;
import ballerina/test;

http:Client testClient = check new ("http://localhost:9090/api");

// --- TEST 1: Database Isolated Logic ---
@test:Config {}
function testDatabaseSeedData() {
    Asset? asset = getAsset("NUST-LIB-3DP-001");
    test:assertNotEquals(asset, (), "Seed asset must exist on startup");
    if asset is Asset {
        test:assertEquals(asset.name, "Pro-Series 3D Printer");
    }
}

// --- TEST 2: GET /assets (Read All) ---
@test:Config {}
function testGetAllAssets() returns error? {
    Asset[] response = check testClient->get("/assets");
    test:assertTrue(response.length() >= 1, "Should retrieve at least the seed record");
}

// --- TEST 3: POST /assets (Create New Asset) ---
@test:Config {}
function testCreateAssetSuccess() returns error? {
    AssetPayload newAsset = {
        assetTag: "UNAM-LIB-SERVER-001",
        name: "Rackmount Database Server",
        description: "Primary database node for campus catalog",
        institution: "University of Namibia",
        site: "Katima Mulilo Campus",
        status: "AVAILABLE",
        dateAcquired: "2026-03-15",
        components: [],
        schedules: [],
        workOrders: []
    };

    http:Response res = check testClient->post("/assets", newAsset);
    test:assertEquals(res.statusCode, 201, "Should create record with HTTP 201");
}

// --- TEST 4: POST /assets Conflict (Duplicate Primary Key) ---
@test:Config {}
function testCreateDuplicateAssetError() returns error? {
    AssetPayload duplicateAsset = {
        assetTag: "NUST-LIB-3DP-001", // Uses seed tag that already exists
        name: "Duplicate Server Entry",
        description: "Testing primary key conflict",
        institution: "NUST",
        site: "Main Library",
        status: "AVAILABLE",
        dateAcquired: "2026-03-15",
        components: [],
        schedules: [],
        workOrders: []
    };

    http:Response res = check testClient->post("/assets", duplicateAsset);
    test:assertEquals(res.statusCode, 409, "Duplicate asset tag should trigger HTTP 409 Conflict");
}

// --- TEST 5: GET /assets/[assetTag] (Read Single Asset) ---
@test:Config {}
function testGetSingleAssetSuccess() returns error? {
    Asset response = check testClient->get("/assets/NUST-LIB-3DP-001");
    test:assertEquals(response.assetTag, "NUST-LIB-3DP-001");
}

// --- TEST 6: GET /assets/[assetTag] Not Found ---
@test:Config {}
function testGetSingleAssetNotFound() returns error? {
    http:Response res = check testClient->get("/assets/NON-EXISTENT-TAG");
    test:assertEquals(res.statusCode, 404, "Unknown assetTag should return HTTP 404");
}

// --- TEST 7: PUT /assets/[assetTag] (Update Record) ---
@test:Config {}
function testUpdateAssetSuccess() returns error? {
    AssetPayload updatePayload = {
        assetTag: "NUST-LIB-3DP-001",
        name: "Pro-Series 3D Printer",
        description: "High-precision laboratory printer - Upgraded",
        institution: "Namibia University of Science and Technology",
        site: "Main Campus Innovation Lab",
        status: "UNDER_MAINTENANCE",
        dateAcquired: "2024-03-10",
        components: [],
        schedules: [],
        workOrders: []
    };

    Asset updatedResponse = check testClient->put("/assets/NUST-LIB-3DP-001", updatePayload);
    test:assertEquals(updatedResponse.status, "UNDER_MAINTENANCE");
}

// --- TEST 8: PUT /assets/[assetTag] Key Mismatch ---
@test:Config {}
function testUpdateAssetMismatchedKeyError() returns error? {
    AssetPayload updatePayload = {
        assetTag: "NUST-LIB-3DP-001",
        name: "Mismatched Tag Payload",
        description: "URL tag and payload tag disagree",
        institution: "NUST",
        site: "Main Library",
        status: "AVAILABLE",
        dateAcquired: "2026-03-15",
        components: [],
        schedules: [],
        workOrders: []
    };

    http:Response res = check testClient->put("/assets/DIFFERENT-TAG-123", updatePayload);
    test:assertEquals(res.statusCode, 400, "Mismatched key in URL vs Body should return HTTP 400 Bad Request");
}

// --- TEST 9: DELETE /assets/[assetTag] (Delete Asset) ---
@test:Config {}
function testDeleteAssetSuccess() returns error? {
    // Delete temporary asset created in test 3
    http:Response res = check testClient->delete("/assets/UNAM-LIB-SERVER-001");
    test:assertEquals(res.statusCode, 200, "Successful deletion should return HTTP 200 OK");
}

// --- TEST 10: DELETE /assets/[assetTag] Not Found ---
@test:Config {}
function testDeleteAssetNotFound() returns error? {
    http:Response res = check testClient->delete("/assets/NON-EXISTENT-TAG");
    test:assertEquals(res.statusCode, 404, "Deleting a non-existent asset should return HTTP 404");
}