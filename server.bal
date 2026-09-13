// B2 + B3 - gRPC server, property state and booking logic
import ballerina/grpc;
import ballerina/time;

type PropertyState record {|
    string propertyId;
    string hostId;
    string name;
    string location;
    string propertyType;
    float pricePerNight;
    PropertyStatus status;
    string description;
    string[] amenities;
|};

type UserState record {|
    string userId;
    string name;
    UserRole role;
    string email;
    string phone;
|};

type TempBooking record {|
    string tempId;
    string propertyId;
    string guestId;
    string checkIn;
    string checkOut;
|};

type ConfirmedBooking record {|
    string bookingId;
    string propertyId;
    string guestId;
    string checkIn;
    string checkOut;
    int nights;
    float totalCost;
|};

map<PropertyState> properties = {};
map<UserState> users = {};
map<TempBooking> tempBookings = {};
map<ConfirmedBooking> bookings = {};

int propertyCounter = 100;
int tempCounter = 500;
int bookingCounter = 900;

listener grpc:Listener rentalListener = new (9190);

@grpc:Descriptor {value: RENTAL_DESC}
service "RentalService" on rentalListener {

    remote function add_property(AddPropertyInput input) returns AddPropertyOutput|error {
        if input.host_id == "" || input.name == "" || input.location == "" {
            return error("host_id, name and location are required");
        }
        if input.price_per_night <= 0.0 {
            return error("price_per_night must be greater than zero");
        }

        UserState? host = users[input.host_id];
        if host is () || host.role != HOST {
            return error("host_id does not belong to a registered host");
        }

        string propertyId = nextPropertyId();
        PropertyState newProperty = {
            propertyId: propertyId,
            hostId: input.host_id,
            name: input.name,
            location: input.location,
            propertyType: input.property_type,
            pricePerNight: input.price_per_night,
            status: AVAILABLE,
            description: input.description,
            amenities: input.amenities.clone()
        };

        lock {
            properties[propertyId] = newProperty;
        }

        return {
            property: propertyToMessage(newProperty),
            message: "Property added",
            success: true
        };
    }

    remote function create_users(stream<UserCreateInput, error?> clientStream)
            returns UserCreateOutput|error {
        int created = 0;
        check clientStream.forEach(function(UserCreateInput input) returns error? {
            if input.user_id == "" || input.name == "" {
                return error("user_id and name are required");
            }
            lock {
                if users.hasKey(input.user_id) {
                    return error(string `user ${input.user_id} already exists`);
                }
                users[input.user_id] = {
                    userId: input.user_id,
                    name: input.name,
                    role: input.role,
                    email: input.email,
                    phone: input.phone
                };
                created += 1;
            }
        });
        return {total_created: created, message: string `${created} users created`};
    }

    remote function update_property(UpdatePropertyInput input) returns AddPropertyOutput|error {
        PropertyState? current = properties[input.property_id];
        if current is () {
            return error("property not found");
        }
        if input.price_per_night <= 0.0 {
            return error("price_per_night must be greater than zero");
        }

        PropertyState changed = current.clone();
        changed.pricePerNight = input.price_per_night;
        changed.status = input.status;
        if input.description != "" {
            changed.description = input.description;
        }

        lock {
            properties[input.property_id] = changed;
        }
        return {property: propertyToMessage(changed), message: "Property updated", success: true};
    }

    remote function remove_property(RemovePropertyInput input) returns RemovePropertyOutput|error {
        PropertyState? current = properties[input.property_id];
        if current is () {
            return error("property not found");
        }
        string region = current.location;

        lock {
            _ = properties.remove(input.property_id);
        }

        Property[] availableInRegion = [];
        foreach PropertyState property in properties {
            if property.location == region && property.status == AVAILABLE {
                availableInRegion.push(propertyToMessage(property));
            }
        }
        return {
            remaining_properties: availableInRegion,
            message: string `Property removed. ${availableInRegion.length()} available in ${region}`
        };
    }

    remote function list_available_properties(SearchFilterInput filter)
            returns stream<Property, grpc:Error?>|error {
        Property[] result = [];
        foreach PropertyState property in properties {
            if property.status != AVAILABLE {
                continue;
            }
            if filter.location != "" && property.location != filter.location {
                continue;
            }
            if filter.property_type != "" && property.propertyType != filter.property_type {
                continue;
            }
            if filter.min_price > 0.0 && property.pricePerNight < filter.min_price {
                continue;
            }
            if filter.max_price > 0.0 && property.pricePerNight > filter.max_price {
                continue;
            }
            result.push(propertyToMessage(property));
        }
        return result.toStream();
    }

    remote function search_property(SearchInput input) returns SearchPropertyOutput|error {
        PropertyState? property = properties[input.property_id];
        if property is () {
            return {
                property: emptyProperty(),
                available: false,
                message: "Not Available"
            };
        }
        boolean available = property.status == AVAILABLE;
        return {
            property: propertyToMessage(property),
            available: available,
            message: available ? "Available" : "Not Available"
        };
    }

    remote function book_property(BookingRequest input) returns TempBookingOutput|error {
        PropertyState? property = properties[input.property_id];
        if property is () {
            return {temp_id: "", message: "Property not found", success: false};
        }
        UserState? guest = users[input.guest_id];
        if guest is () || guest.role != GUEST {
            return {temp_id: "", message: "guest_id is not a registered guest", success: false};
        }
        if property.status != AVAILABLE {
            return {temp_id: "", message: "Property not available", success: false};
        }
        if !validDateRange(input.check_in, input.check_out) {
            return {temp_id: "", message: "Invalid dates or check-out is not after check-in", success: false};
        }

        string tempId = nextTempId();
        TempBooking temp = {
            tempId: tempId,
            propertyId: input.property_id,
            guestId: input.guest_id,
            checkIn: input.check_in,
            checkOut: input.check_out
        };
        lock {
            tempBookings[tempId] = temp;
        }
        return {temp_id: tempId, message: "Booking request added to temporary cart", success: true};
    }

    remote function confirm_booking(ConfirmBookingRequest input)
            returns BookingConfirmationOutput|error {
        TempBooking? temp = tempBookings[input.temp_id];
        if temp is () {
            return error("temporary booking not found");
        }

        PropertyState? property = properties[temp.propertyId];
        if property is () {
            return error("property no longer exists");
        }
        if property.status != AVAILABLE {
            return error("property is no longer available");
        }

        foreach ConfirmedBooking existing in bookings {
            if existing.propertyId == temp.propertyId &&
                    check rangesOverlap(temp.checkIn, temp.checkOut, existing.checkIn, existing.checkOut) {
                return error("property is already booked for some of those dates");
            }
        }

        int nights = check countNights(temp.checkIn, temp.checkOut);
        float total = property.pricePerNight * <float>nights;
        string bookingId = nextBookingId();
        ConfirmedBooking confirmed = {
            bookingId: bookingId,
            propertyId: temp.propertyId,
            guestId: temp.guestId,
            checkIn: temp.checkIn,
            checkOut: temp.checkOut,
            nights: nights,
            totalCost: total
        };

        lock {
            bookings[bookingId] = confirmed;
            _ = tempBookings.remove(input.temp_id);
        }

        return {
            booking_id: bookingId,
            property_id: confirmed.propertyId,
            guest_id: confirmed.guestId,
            check_in: confirmed.checkIn,
            check_out: confirmed.checkOut,
            nights: nights,
            total_cost: total,
            confirmed: true,
            message: "Booking confirmed"
        };
    }
}

function emptyProperty() returns Property {
    return {
        property_id: "",
        host_id: "",
        name: "",
        location: "",
        property_type: "",
        price_per_night: 0.0,
        status: STATUS_REMOVED,
        description: "",
        amenities: []
    };
}

function propertyToMessage(PropertyState property) returns Property {
    return {
        property_id: property.propertyId,
        host_id: property.hostId,
        name: property.name,
        location: property.location,
        property_type: property.propertyType,
        price_per_night: property.pricePerNight,
        status: property.status,
        description: property.description,
        amenities: property.amenities.clone()
    };
}

function validDateRange(string checkIn, string checkOut) returns boolean {
    time:Utc|error start = time:utcFromString(checkIn + "T00:00:00Z");
    time:Utc|error finish = time:utcFromString(checkOut + "T00:00:00Z");
    if start is error || finish is error {
        return false;
    }
    return start[0] < finish[0];
}

function rangesOverlap(string startA, string endA, string startB, string endB) returns boolean|error {
    time:Utc aStart = check time:utcFromString(startA + "T00:00:00Z");
    time:Utc aEnd = check time:utcFromString(endA + "T00:00:00Z");
    time:Utc bStart = check time:utcFromString(startB + "T00:00:00Z");
    time:Utc bEnd = check time:utcFromString(endB + "T00:00:00Z");
    return aStart[0] < bEnd[0] && bStart[0] < aEnd[0];
}

function countNights(string checkIn, string checkOut) returns int|error {
    time:Utc start = check time:utcFromString(checkIn + "T00:00:00Z");
    time:Utc finish = check time:utcFromString(checkOut + "T00:00:00Z");
    int seconds = finish[0] - start[0];
    if seconds <= 0 {
        return error("check-out must be after check-in");
    }
    return seconds / 86400;
}

function nextPropertyId() returns string {
    lock {
        propertyCounter += 1;
        return string `PROP-${propertyCounter}`;
    }
}

function nextTempId() returns string {
    lock {
        tempCounter += 1;
        return string `TEMP-${tempCounter}`;
    }
}

function nextBookingId() returns string {
    lock {
        bookingCounter += 1;
        return string `BOOK-${bookingCounter}`;
    }
}
