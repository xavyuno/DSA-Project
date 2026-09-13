// A2 + A4 backend helpers - asset loaning/booking and request handling
public function assetFromPayload(AssetPayload payload) returns Asset {
    return {
        assetTag: payload.assetTag,
        name: payload.name,
        description: payload.description,
        institution: payload.institution,
        site: payload.site,
        status: payload.status,
        dateAcquired: payload.dateAcquired,
        components: payload.components.clone(),
        schedules: payload.schedules.clone(),
        workOrders: payload.workOrders.clone()
    };
}

public function loanAsset(string assetTag, LoanRequest request) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }
    if current.status != "AVAILABLE" {
        return error("asset is not available for loan");
    }
    if !validDate(request.dueDate) {
        return error("dueDate must use YYYY-MM-DD");
    }

    Asset changed = current.clone();
    changed.status = "LOANED_OUT";
    changed.schedules.push({
        scheduleId: newSmallId("LOAN"),
        'type: "LOAN_RETURN",
        dueDate: request.dueDate,
        description: string `Return date for ${request.borrower}`,
        bookedBy: request.borrower
    });
    _ = updateAsset(changed);
    return changed;
}

public function bookAsset(string assetTag, BookingRequest request) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }
    if current.status != "AVAILABLE" {
        return error("asset cannot be booked in its current state");
    }
    if !validDate(request.startDate) || !validDate(request.endDate) {
        return error("booking dates must use YYYY-MM-DD");
    }
    if !(check isBefore(request.startDate, request.endDate)) {
        return error("end date must be after start date");
    }

    foreach Schedule schedule in current.schedules {
        if schedule.'type == "BOOKING" && schedule.startDate is string && schedule.endDate is string {
            if check dateRangesOverlap(request.startDate, request.endDate,
                    <string>schedule.startDate, <string>schedule.endDate) {
                return error("booking overlaps an existing booking");
            }
        }
    }

    Asset changed = current.clone();
    changed.schedules.push({
        scheduleId: newSmallId("BOOK"),
        'type: "BOOKING",
        dueDate: request.endDate,
        description: request.description,
        bookedBy: request.bookedBy,
        startDate: request.startDate,
        endDate: request.endDate
    });
    _ = updateAsset(changed);
    return changed;
}

function dateRangesOverlap(string startA, string endA, string startB, string endB) returns boolean|error {
    boolean aStartsBeforeBEnds = check isBefore(startA, endB);
    boolean bStartsBeforeAEnds = check isBefore(startB, endA);
    return aStartsBeforeBEnds && bStartsBeforeAEnds;
}

int smallIdCounter = 1000;

function newSmallId(string prefix) returns string {
    lock {
        smallIdCounter += 1;
        return string `${prefix}-${smallIdCounter}`;
    }
}
