public type AssetStatus "AVAILABLE"|"LOANED_OUT"|"UNDER_MAINTENANCE"|"DISPOSED";

public type WorkOrderStatus "OPEN"|"IN_PROGRESS"|"CLOSED";

public type SubTask record {|
    string taskId;
    string description;
|};

public type WorkOrder record {|
    string orderId;
    WorkOrderStatus status;
    string description;
    SubTask[] tasks = [];
|};

public type Schedule record {|
    string scheduleId;
    string 'type;
    string dueDate;
    string description;
|};

public type Component record {|
    string compId;
    string name;
    string description;
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

public type ErrorResponse record {|
    string message;
|};