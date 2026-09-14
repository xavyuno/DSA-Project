// A1 - API & database foundation
// group credit note: this file already existed in the repo before this cleanup.
// the original version had the Asset/Component/Schedule/SubTask/WorkOrder models and AssetPayload.
// later changes only filled the missing assignment bits: OCCUPIED, schedule types, institution + loan/booking models,
// status view and the small done flag on work-order tasks.
// exact original author isnt visible in the zip copy, so put their name here from github history before final submission.
public type AssetStatus "AVAILABLE"|"LOANED_OUT"|"OCCUPIED"|"UNDER_MAINTENANCE"|"DISPOSED";
public type ScheduleType "MAINTENANCE"|"SERVICING"|"BOOKING"|"LOAN_RETURN";
public type WorkOrderStatus "OPEN"|"IN_PROGRESS"|"CLOSED";

public type Component record {|
    string compId;
    string name;
    string description;
|};

public type Schedule record {|
    string scheduleId;
    ScheduleType 'type;
    string dueDate;
    string description;
    string? bookedBy = ();
    string? startDate = ();
    string? endDate = ();
|};

public type SubTask record {|
    string taskId;
    string description;
    boolean done = false;
|};

public type WorkOrder record {|
    string orderId;
    WorkOrderStatus status;
    string description;
    SubTask[] tasks = [];
|};

public type Asset record {|
    readonly string assetTag;
    string name;
    string description;
    string institution;
    string site;
    AssetStatus status;
    string dateAcquired;
    Component[] components = [];
    Schedule[] schedules = [];
    WorkOrder[] workOrders = [];
|};

public type AssetPayload record {|
    string assetTag;
    string name;
    string description;
    string institution;
    string site;
    AssetStatus status;
    string dateAcquired;
    Component[] components = [];
    Schedule[] schedules = [];
    WorkOrder[] workOrders = [];
|};

public type Institution record {|
    readonly string code;
    string name;
    string[] sites = [];
|};

public type InstitutionPayload record {|
    string code;
    string name;
    string[] sites = [];
|};

public type LoanRequest record {|
    string borrower;
    string dueDate;
|};

public type BookingRequest record {|
    string bookedBy;
    string startDate;
    string endDate;
    string description = "Resource booking";
|};

public type StatusView record {|
    string assetTag;
    AssetStatus status;
    Schedule[] schedules;
|};
