// A1 + A2 - in-memory tables, CRUD, filtering and overdue queries
// group credit note: the original repo already had assetTable plus get/add/update/remove asset functions.
// later changes kept that base and added institution storage, a couple more sample assets, filters and overdue/date checks.
// the zip doesnt include git history, so the original member name should be filled in from github blame/history.
import ballerina/time;

table<Institution> key(code) institutionTable = table [
    {code: "NUST", name: "Namibia University of Science and Technology", sites: ["Main Campus", "Innovation Lab"]},
    {code: "UNAM", name: "University of Namibia", sites: ["Main Campus", "Hage Geingob Campus"]}
];

table<Asset> key(assetTag) assetTable = table [
    {
        assetTag: "NUST-LIB-3DP-001",
        name: "Pro-Series 3D Printer",
        description: "High-precision laboratory printer for prototype work.",
        institution: "NUST",
        site: "Innovation Lab",
        status: "AVAILABLE",
        dateAcquired: "2024-03-10",
        components: [
            {compId: "C101", name: "Stepper Motor", description: "X-axis motor"}
        ],
        schedules: [
            {scheduleId: "SCH-882", 'type: "MAINTENANCE", dueDate: "2026-09-01", description: "Quarterly calibration"}
        ],
        workOrders: []
    },
    {
        assetTag: "NUST-ROOM-MR-101",
        name: "Engineering Meeting Room 101",
        description: "Small meeting room with projector and whiteboard.",
        institution: "NUST",
        site: "Main Campus",
        status: "AVAILABLE",
        dateAcquired: "2022-01-15",
        components: [],
        schedules: [],
        workOrders: []
    },
    {
        assetTag: "UNAM-ICT-LAP-014",
        name: "Dell Latitude Laptop",
        description: "Loan laptop used by students during practical sessions.",
        institution: "UNAM",
        site: "Main Campus",
        status: "AVAILABLE",
        dateAcquired: "2025-02-18",
        components: [],
        schedules: [],
        workOrders: []
    }
];

public function getAllAssets() returns Asset[] {
    return assetTable.toArray().clone();
}

public function getAsset(string assetTag) returns Asset? {
    Asset? found = assetTable[assetTag];
    if found is Asset {
        return found.clone();
    }
    return ();
}

public function addAsset(Asset asset) returns boolean {
    lock {
        if assetTable.hasKey(asset.assetTag) {
            return false;
        }
        assetTable.add(asset.clone());
    }
    return true;
}

public function updateAsset(Asset asset) returns boolean {
    lock {
        if !assetTable.hasKey(asset.assetTag) {
            return false;
        }
        assetTable.put(asset.clone());
    }
    return true;
}

public function deleteAsset(string assetTag) returns boolean {
    lock {
        if !assetTable.hasKey(assetTag) {
            return false;
        }
        _ = assetTable.remove(assetTag);
    }
    return true;
}

public function filterAssets(string? institution, string? site) returns Asset[] {
    Asset[] result = [];
    foreach Asset asset in assetTable {
        boolean institutionMatches = institution is () || asset.institution == institution;
        boolean siteMatches = site is () || asset.site == site;
        if institutionMatches && siteMatches {
            result.push(asset.clone());
        }
    }
    return result;
}

public function getInstitutions() returns Institution[] {
    return institutionTable.toArray().clone();
}

public function addInstitution(Institution institution) returns boolean {
    lock {
        if institutionTable.hasKey(institution.code) {
            return false;
        }
        institutionTable.add(institution.clone());
    }
    return true;
}

public function deleteInstitution(string code) returns boolean {
    lock {
        if !institutionTable.hasKey(code) {
            return false;
        }
        _ = institutionTable.remove(code);
    }
    return true;
}

public function todayIsoDate() returns string {
    time:Civil today = time:utcToCivil(time:utcNow());
    string month = twoDigits(today.month);
    string day = twoDigits(today.day);
    return string `${today.year}-${month}-${day}`;
}

function twoDigits(int value) returns string {
    if value < 10 {
        return string `0${value}`;
    }
    return string `${value}`;
}

public function validDate(string value) returns boolean {
    time:Utc|error parsed = time:utcFromString(value + "T00:00:00Z");
    return parsed is time:Utc;
}

public function isBefore(string left, string right) returns boolean|error {
    time:Utc leftTime = check time:utcFromString(left + "T00:00:00Z");
    time:Utc rightTime = check time:utcFromString(right + "T00:00:00Z");
    return leftTime[0] < rightTime[0];
}

public function getOverdueAssets(string asOf) returns Asset[]|error {
    if !validDate(asOf) {
        return error("asOf must use YYYY-MM-DD");
    }

    Asset[] overdue = [];
    foreach Asset asset in assetTable {
        boolean addIt = false;
        foreach Schedule schedule in asset.schedules {
            if (schedule.'type == "MAINTENANCE" || schedule.'type == "SERVICING") &&
                    check isBefore(schedule.dueDate, asOf) {
                addIt = true;
                break;
            }
        }
        if addIt {
            overdue.push(asset.clone());
        }
    }
    return overdue;
}
