// B4 - Ballerina gRPC client demo
import ballerina/grpc;
import ballerina/io;

RentalServiceClient rental = check new ("http://localhost:9190");

public function main() returns error? {
    io:println("Rental Accommodation gRPC client demo");

    check createUsers();

    AddPropertyOutput first = check rental->add_property({
        host_id: "HOST-1",
        name: "Atlantic View Flat",
        location: "Swakopmund",
        property_type: "Apartment",
        price_per_night: 850.0,
        description: "Two bedroom flat close to the beach",
        amenities: ["WiFi", "Parking"]
    });
    io:println("Added: ", first.property.property_id);

    AddPropertyOutput second = check rental->add_property({
        host_id: "HOST-1",
        name: "Desert Stopover Room",
        location: "Swakopmund",
        property_type: "Room",
        price_per_night: 520.0,
        description: "Simple overnight room",
        amenities: ["WiFi"]
    });
    io:println("Added: ", second.property.property_id);

    AddPropertyOutput updated = check rental->update_property({
        property_id: first.property.property_id,
        price_per_night: 900.0,
        status: AVAILABLE,
        description: "Two bedroom flat close to the beach - updated price"
    });
    io:println("Updated price: ", updated.property.price_per_night);

    io:println("\nAvailable properties in Swakopmund:");
    stream<Property, grpc:Error?> available = check rental->list_available_properties({
        location: "Swakopmund",
        min_price: 0.0,
        max_price: 1000.0,
        property_type: ""
    });
    check available.forEach(function(Property property) {
        io:println(property.property_id, " | ", property.name, " | N$", property.price_per_night);
    });

    SearchPropertyOutput search = check rental->search_property({property_id: first.property.property_id});
    io:println("\nSearch result: ", search.message);

    TempBookingOutput temp = check rental->book_property({
        property_id: first.property.property_id,
        guest_id: "GUEST-1",
        check_in: "2026-10-10",
        check_out: "2026-10-13"
    });
    if !temp.success {
        return error(temp.message);
    }
    io:println("Temporary cart id: ", temp.temp_id);

    BookingConfirmationOutput confirmation = check rental->confirm_booking({temp_id: temp.temp_id});
    io:println("Confirmed booking ", confirmation.booking_id,
        " | nights: ", confirmation.nights, " | total: N$", confirmation.total_cost);

    RemovePropertyOutput removed = check rental->remove_property({property_id: second.property.property_id});
    io:println("Removed second property. Available in region now: ", removed.remaining_properties.length());
}

function createUsers() returns error? {
    var userStream = check rental->create_users();

    check userStream->sendUserCreateInput({
        user_id: "HOST-1",
        name: "Maria Host",
        role: HOST,
        email: "maria@example.test",
        phone: "0810000001"
    });
    check userStream->sendUserCreateInput({
        user_id: "GUEST-1",
        name: "John Guest",
        role: GUEST,
        email: "john@example.test",
        phone: "0810000002"
    });
    check userStream->complete();

    UserCreateOutput? result = check userStream->receiveUserCreateOutput();
    if result is UserCreateOutput {
        io:println(result.message);
    }
}
