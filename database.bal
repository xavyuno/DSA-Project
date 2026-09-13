isolated table<Asset> key(assetTag) assetTable = table [
    {
        assetTag: "NUST-LIB-3DP-001",
        name: "Pro-Series 3D Printer",
        description: "High-precision laboratory printer for simulation and prototype development.",
        institution: "Namibia University of Science and Technology",
        site: "Main Campus Innovation Lab",
        status: "AVAILABLE",
        dateAcquired: "2024-03-10",
        components: [],
        schedules: [],
        workOrders: []
    }
];

public isolated function getAllAssets() returns Asset[] {
    lock {
        // Clone the array to safely return it from an isolated function
        return assetTable.toArray().clone();
    }
}

public isolated function getAsset(string assetTag) returns Asset? {
    lock {
        if assetTable.hasKey(assetTag) {
            // Clone the single asset record to safely return it
            return assetTable.get(assetTag).clone();
        }
        return ();
    }
}

public isolated function addAsset(Asset newAsset) returns boolean {
    lock {
        if assetTable.hasKey(newAsset.assetTag) {
            return false;
        }
        // Clone as read-only to satisfy Ballerina's isolation rules
        assetTable.add(newAsset.cloneReadOnly());
        return true;
    }
}

public isolated function updateAsset(Asset updated) returns boolean {
    lock {
        if !assetTable.hasKey(updated.assetTag) {
            return false;
        }
        // Clone as read-only to satisfy Ballerina's isolation rules
        assetTable.put(updated.cloneReadOnly());
        return true;
    }
}

public isolated function removeAsset(string assetTag) returns boolean {
    lock {
        if !assetTable.hasKey(assetTag) {
            return false;
        }
        _ = assetTable.remove(assetTag);
        return true;
    }
}