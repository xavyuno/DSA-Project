// A4 - Ballerina HTTP command-line client
import ballerina/http;
import ballerina/io;

http:Client libraryApi = check new ("http://localhost:9090/api");

type Asset record {|
    string assetTag;
    string name;
    string description;
    string institution;
    string site;
    string status;
    string dateAcquired;
    json[] components = [];
    json[] schedules = [];
    json[] workOrders = [];
|};

public function main() returns error? {
    io:println("Library and Resource Management Client");
    io:println("Server expected at http://localhost:9090/api");

    boolean running = true;
    while running {
        io:println("\n1. Loan an asset");
        io:println("2. Book a room/lab");
        io:println("3. Global asset view");
        io:println("4. Campus/institution view");
        io:println("5. Overdue dashboard");
        io:println("6. Add servicing schedule");
        io:println("0. Exit");
        string choice = io:readln("Choice: ");

        if choice == "1" {
            check loanMenu();
        } else if choice == "2" {
            check bookingMenu();
        } else if choice == "3" {
            check showAll();
        } else if choice == "4" {
            check campusView();
        } else if choice == "5" {
            check overdueView();
        } else if choice == "6" {
            check scheduleMenu();
        } else if choice == "0" {
            running = false;
        } else {
            io:println("Unknown option");
        }
    }
}

function loanMenu() returns error? {
    string assetTag = io:readln("Asset tag: ");
    string borrower = io:readln("Borrower name/id: ");
    string dueDate = io:readln("Return date (YYYY-MM-DD): ");
    http:Response response = check libraryApi->post(string `/assets/${assetTag}/loan`,
        {borrower: borrower, dueDate: dueDate});
    io:println("HTTP ", response.statusCode, " - ", check response.getTextPayload());
}

function bookingMenu() returns error? {
    string assetTag = io:readln("Room/lab asset tag: ");
    string bookedBy = io:readln("Booked by: ");
    string startDate = io:readln("Start date (YYYY-MM-DD): ");
    string endDate = io:readln("End date (YYYY-MM-DD): ");
    http:Response response = check libraryApi->post(string `/assets/${assetTag}/book`, {
        bookedBy: bookedBy,
        startDate: startDate,
        endDate: endDate,
        description: "Client booking"
    });
    io:println("HTTP ", response.statusCode, " - ", check response.getTextPayload());
}

function showAll() returns error? {
    Asset[] assets = check libraryApi->get("/assets");
    printAssets(assets);
}

function campusView() returns error? {
    io:println("Use short codes such as NUST or UNAM. Site can be left empty.");
    string institution = io:readln("Institution code: ");
    string site = io:readln("Site (optional, avoid spaces or use %20): ");
    string path = string `/assets?institution=${institution}`;
    if site != "" {
        path += string `&site=${site}`;
    }
    Asset[] assets = check libraryApi->get(path);
    printAssets(assets);
}

function overdueView() returns error? {
    string asOf = io:readln("Check date (YYYY-MM-DD, blank = today): ");
    string path = asOf == "" ? "/overdue" : string `/overdue?asOf=${asOf}`;
    Asset[] assets = check libraryApi->get(path);
    io:println("Overdue maintenance/resources:");
    printAssets(assets);
}

function scheduleMenu() returns error? {
    string assetTag = io:readln("Asset tag: ");
    string scheduleId = io:readln("Schedule id: ");
    string dueDate = io:readln("Due date (YYYY-MM-DD): ");
    string description = io:readln("Description: ");
    http:Response response = check libraryApi->post(string `/assets/${assetTag}/schedules`, {
        scheduleId: scheduleId,
        'type: "SERVICING",
        dueDate: dueDate,
        description: description
    });
    io:println("HTTP ", response.statusCode, " - ", check response.getTextPayload());
}

function printAssets(Asset[] assets) {
    if assets.length() == 0 {
        io:println("No assets found.");
        return;
    }
    foreach Asset asset in assets {
        io:println(asset.assetTag, " | ", asset.name, " | ", asset.institution,
            " | ", asset.site, " | ", asset.status);
    }
}
