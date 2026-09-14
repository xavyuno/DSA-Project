// A3 - components, schedules, work orders and work-order tasks
public function addComponentToAsset(string assetTag, Component component) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }
    foreach Component item in current.components {
        if item.compId == component.compId {
            return error("component id already exists");
        }
    }

    Asset changed = current.clone();
    changed.components.push(component.clone());
    _ = updateAsset(changed);
    return changed;
}

public function removeComponentFromAsset(string assetTag, string compId) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }

    Component[] kept = [];
    boolean found = false;
    foreach Component component in current.components {
        if component.compId == compId {
            found = true;
        } else {
            kept.push(component.clone());
        }
    }
    if !found {
        return error("component not found");
    }

    Asset changed = current.clone();
    changed.components = kept;
    _ = updateAsset(changed);
    return changed;
}

public function addScheduleToAsset(string assetTag, Schedule schedule) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }
    if !validDate(schedule.dueDate) {
        return error("dueDate must use YYYY-MM-DD");
    }
    foreach Schedule item in current.schedules {
        if item.scheduleId == schedule.scheduleId {
            return error("schedule id already exists");
        }
    }

    Asset changed = current.clone();
    changed.schedules.push(schedule.clone());
    _ = updateAsset(changed);
    return changed;
}

public function updateScheduleOnAsset(string assetTag, string scheduleId, Schedule replacement) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }
    if scheduleId != replacement.scheduleId {
        return error("schedule id in path and body must match");
    }
    if !validDate(replacement.dueDate) {
        return error("dueDate must use YYYY-MM-DD");
    }

    Schedule[] changedSchedules = [];
    boolean found = false;
    foreach Schedule schedule in current.schedules {
        if schedule.scheduleId == scheduleId {
            changedSchedules.push(replacement.clone());
            found = true;
        } else {
            changedSchedules.push(schedule.clone());
        }
    }
    if !found {
        return error("schedule not found");
    }

    Asset changed = current.clone();
    changed.schedules = changedSchedules;
    _ = updateAsset(changed);
    return changed;
}

public function removeScheduleFromAsset(string assetTag, string scheduleId) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }

    Schedule[] kept = [];
    boolean found = false;
    foreach Schedule schedule in current.schedules {
        if schedule.scheduleId == scheduleId {
            found = true;
        } else {
            kept.push(schedule.clone());
        }
    }
    if !found {
        return error("schedule not found");
    }

    Asset changed = current.clone();
    changed.schedules = kept;
    _ = updateAsset(changed);
    return changed;
}

public function openWorkOrder(string assetTag, WorkOrder workOrder) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }
    foreach WorkOrder item in current.workOrders {
        if item.orderId == workOrder.orderId {
            return error("work order id already exists");
        }
    }

    WorkOrder opened = workOrder.clone();
    opened.status = "OPEN";
    Asset changed = current.clone();
    changed.workOrders.push(opened);
    _ = updateAsset(changed);
    return changed;
}

public function replaceWorkOrder(string assetTag, string orderId, WorkOrder replacement) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }
    if replacement.orderId != orderId {
        return error("work order id in path and body must match");
    }

    WorkOrder[] orders = [];
    boolean found = false;
    foreach WorkOrder 'order in current.workOrders {
        if 'order.orderId == orderId {
            orders.push(replacement.clone());
            found = true;
        } else {
            orders.push('order.clone());
        }
    }
    if !found {
        return error("work order not found");
    }

    Asset changed = current.clone();
    changed.workOrders = orders;
    _ = updateAsset(changed);
    return changed;
}

public function closeWorkOrder(string assetTag, string orderId) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }

    WorkOrder[] orders = [];
    boolean found = false;
    foreach WorkOrder 'order in current.workOrders {
        WorkOrder changedOrder = 'order.clone();
        if changedOrder.orderId == orderId {
            changedOrder.status = "CLOSED";
            found = true;
        }
        orders.push(changedOrder);
    }
    if !found {
        return error("work order not found");
    }

    Asset changed = current.clone();
    changed.workOrders = orders;
    _ = updateAsset(changed);
    return changed;
}

public function addTaskToWorkOrder(string assetTag, string orderId, SubTask task) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }

    WorkOrder[] orders = [];
    boolean orderFound = false;
    foreach WorkOrder 'order in current.workOrders {
        WorkOrder changedOrder = 'order.clone();
        if changedOrder.orderId == orderId {
            orderFound = true;
            foreach SubTask item in changedOrder.tasks {
                if item.taskId == task.taskId {
                    return error("task id already exists");
                }
            }
            changedOrder.tasks.push(task.clone());
        }
        orders.push(changedOrder);
    }
    if !orderFound {
        return error("work order not found");
    }

    Asset changed = current.clone();
    changed.workOrders = orders;
    _ = updateAsset(changed);
    return changed;
}

public function removeTaskFromWorkOrder(string assetTag, string orderId, string taskId) returns Asset|error {
    Asset? current = getAsset(assetTag);
    if current is () {
        return error("asset not found");
    }

    WorkOrder[] orders = [];
    boolean orderFound = false;
    boolean taskFound = false;
    foreach WorkOrder 'order in current.workOrders {
        WorkOrder changedOrder = 'order.clone();
        if changedOrder.orderId == orderId {
            orderFound = true;
            SubTask[] kept = [];
            foreach SubTask task in changedOrder.tasks {
                if task.taskId == taskId {
                    taskFound = true;
                } else {
                    kept.push(task.clone());
                }
            }
            changedOrder.tasks = kept;
        }
        orders.push(changedOrder);
    }
    if !orderFound {
        return error("work order not found");
    }
    if !taskFound {
        return error("task not found");
    }

    Asset changed = current.clone();
    changed.workOrders = orders;
    _ = updateAsset(changed);
    return changed;
}
