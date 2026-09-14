import ballerina/grpc;
import ballerina/protobuf;

public const string RENTAL_DESC = "0A0C72656E74616C2E70726F746F22AA020A0850726F7065727479121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F7374496412120A046E616D6518032001280952046E616D65121A0A086C6F636174696F6E18042001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180520012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180620012801520D70726963655065724E6967687412270A0673746174757318072001280E320F2E50726F7065727479537461747573520673746174757312200A0B6465736372697074696F6E180820012809520B6465736372697074696F6E121C0A09616D656E69746965731809200328095209616D656E6974696573227E0A045573657212170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D65121D0A04726F6C6518032001280E32092E55736572526F6C655204726F6C6512140A05656D61696C1804200128095205656D61696C12140A0570686F6E65180520012809520570686F6E652289010A0F55736572437265617465496E70757412170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D65121D0A04726F6C6518032001280E32092E55736572526F6C655204726F6C6512140A05656D61696C1804200128095205656D61696C12140A0570686F6E65180520012809520570686F6E6522510A10557365724372656174654F757470757412230A0D746F74616C5F63726561746564180120012805520C746F74616C4372656174656412180A076D65737361676518022001280952076D65737361676522E8010A1041646450726F7065727479496E70757412170A07686F73745F69641801200128095206686F7374496412120A046E616D6518022001280952046E616D65121A0A086C6F636174696F6E18032001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180420012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180520012801520D70726963655065724E6967687412200A0B6465736372697074696F6E180620012809520B6465736372697074696F6E121C0A09616D656E69746965731807200328095209616D656E6974696573226E0A1141646450726F70657274794F757470757412250A0870726F706572747918012001280B32092E50726F7065727479520870726F706572747912180A076D65737361676518022001280952076D65737361676512180A077375636365737318032001280852077375636365737322A9010A1355706461746550726F7065727479496E707574121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412260A0F70726963655F7065725F6E69676874180220012801520D70726963655065724E6967687412270A0673746174757318032001280E320F2E50726F7065727479537461747573520673746174757312200A0B6465736372697074696F6E180420012809520B6465736372697074696F6E22570A1352656D6F766550726F7065727479496E707574121F0A0B70726F70657274795F6964180120012809520A70726F70657274794964121F0A0B686F73745F726567696F6E180220012809520A686F7374526567696F6E226E0A1452656D6F766550726F70657274794F7574707574123C0A1472656D61696E696E675F70726F7065727469657318012003280B32092E50726F7065727479521372656D61696E696E6750726F7065727469657312180A076D65737361676518022001280952076D657373616765222E0A0B536561726368496E707574121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496422750A1453656172636850726F70657274794F757470757412250A0870726F706572747918012001280B32092E50726F7065727479520870726F7065727479121C0A09617661696C61626C651802200128085209617661696C61626C6512180A076D65737361676518032001280952076D657373616765228E010A1153656172636846696C746572496E707574121A0A086C6F636174696F6E18012001280952086C6F636174696F6E121B0A096D696E5F707269636518022001280152086D696E5072696365121B0A096D61785F707269636518032001280152086D6178507269636512230A0D70726F70657274795F74797065180420012809520C70726F7065727479547970652284010A0E426F6F6B696E6752657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412190A0867756573745F696418022001280952076775657374496412190A08636865636B5F696E1803200128095207636865636B496E121B0A09636865636B5F6F75741804200128095208636865636B4F757422600A1154656D70426F6F6B696E674F757470757412170A0774656D705F6964180120012809520674656D70496412180A076D65737361676518022001280952076D65737361676512180A077375636365737318032001280852077375636365737322300A15436F6E6669726D426F6F6B696E675265717565737412170A0774656D705F6964180120012809520674656D704964229D020A19426F6F6B696E67436F6E6669726D6174696F6E4F7574707574121D0A0A626F6F6B696E675F69641801200128095209626F6F6B696E674964121F0A0B70726F70657274795F6964180220012809520A70726F7065727479496412190A0867756573745F696418032001280952076775657374496412190A08636865636B5F696E1804200128095207636865636B496E121B0A09636865636B5F6F75741805200128095208636865636B4F757412160A066E696768747318062001280552066E6967687473121D0A0A746F74616C5F636F73741807200128015209746F74616C436F7374121C0A09636F6E6669726D65641808200128085209636F6E6669726D656412180A076D65737361676518092001280952076D6573736167652A3F0A0E50726F7065727479537461747573120D0A09415641494C41424C451000120A0A06424F4F4B4544100112120A0E5354415455535F52454D4F56454410022A1F0A0855736572526F6C6512080A04484F5354100012090A054755455354100132ED030A0D52656E74616C5365727669636512350A0C6164645F70726F706572747912112E41646450726F7065727479496E7075741A122E41646450726F70657274794F757470757412350A0C6372656174655F757365727312102E55736572437265617465496E7075741A112E557365724372656174654F75747075742801123B0A0F7570646174655F70726F706572747912142E55706461746550726F7065727479496E7075741A122E41646450726F70657274794F7574707574123E0A0F72656D6F76655F70726F706572747912142E52656D6F766550726F7065727479496E7075741A152E52656D6F766550726F70657274794F7574707574123C0A196C6973745F617661696C61626C655F70726F7065727469657312122E53656172636846696C746572496E7075741A092E50726F7065727479300112360A0F7365617263685F70726F7065727479120C2E536561726368496E7075741A152E53656172636850726F70657274794F757470757412340A0D626F6F6B5F70726F7065727479120F2E426F6F6B696E67526571756573741A122E54656D70426F6F6B696E674F757470757412450A0F636F6E6669726D5F626F6F6B696E6712162E436F6E6669726D426F6F6B696E67526571756573741A1A2E426F6F6B696E67436F6E6669726D6174696F6E4F7574707574620670726F746F33";

public isolated client class RentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, RENTAL_DESC);
    }

    isolated remote function add_property(AddPropertyInput|ContextAddPropertyInput req) returns AddPropertyOutput|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyInput message;
        if req is ContextAddPropertyInput {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/add_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddPropertyOutput>result;
    }

    isolated remote function add_propertyContext(AddPropertyInput|ContextAddPropertyInput req) returns ContextAddPropertyOutput|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyInput message;
        if req is ContextAddPropertyInput {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/add_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddPropertyOutput>result, headers: respHeaders};
    }

    isolated remote function update_property(UpdatePropertyInput|ContextUpdatePropertyInput req) returns AddPropertyOutput|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyInput message;
        if req is ContextUpdatePropertyInput {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/update_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddPropertyOutput>result;
    }

    isolated remote function update_propertyContext(UpdatePropertyInput|ContextUpdatePropertyInput req) returns ContextAddPropertyOutput|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyInput message;
        if req is ContextUpdatePropertyInput {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/update_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddPropertyOutput>result, headers: respHeaders};
    }

    isolated remote function remove_property(RemovePropertyInput|ContextRemovePropertyInput req) returns RemovePropertyOutput|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyInput message;
        if req is ContextRemovePropertyInput {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemovePropertyOutput>result;
    }

    isolated remote function remove_propertyContext(RemovePropertyInput|ContextRemovePropertyInput req) returns ContextRemovePropertyOutput|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyInput message;
        if req is ContextRemovePropertyInput {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemovePropertyOutput>result, headers: respHeaders};
    }

    isolated remote function search_property(SearchInput|ContextSearchInput req) returns SearchPropertyOutput|grpc:Error {
        map<string|string[]> headers = {};
        SearchInput message;
        if req is ContextSearchInput {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/search_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchPropertyOutput>result;
    }

    isolated remote function search_propertyContext(SearchInput|ContextSearchInput req) returns ContextSearchPropertyOutput|grpc:Error {
        map<string|string[]> headers = {};
        SearchInput message;
        if req is ContextSearchInput {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/search_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchPropertyOutput>result, headers: respHeaders};
    }

    isolated remote function book_property(BookingRequest|ContextBookingRequest req) returns TempBookingOutput|grpc:Error {
        map<string|string[]> headers = {};
        BookingRequest message;
        if req is ContextBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/book_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <TempBookingOutput>result;
    }

    isolated remote function book_propertyContext(BookingRequest|ContextBookingRequest req) returns ContextTempBookingOutput|grpc:Error {
        map<string|string[]> headers = {};
        BookingRequest message;
        if req is ContextBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/book_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <TempBookingOutput>result, headers: respHeaders};
    }

    isolated remote function confirm_booking(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns BookingConfirmationOutput|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <BookingConfirmationOutput>result;
    }

    isolated remote function confirm_bookingContext(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ContextBookingConfirmationOutput|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <BookingConfirmationOutput>result, headers: respHeaders};
    }

    isolated remote function create_users() returns Create_usersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("RentalService/create_users");
        return new Create_usersStreamingClient(sClient);
    }

    isolated remote function list_available_properties(SearchFilterInput|ContextSearchFilterInput req) returns stream<Property, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        SearchFilterInput message;
        if req is ContextSearchFilterInput {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("RentalService/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return new stream<Property, grpc:Error?>(outputStream);
    }

    isolated remote function list_available_propertiesContext(SearchFilterInput|ContextSearchFilterInput req) returns ContextPropertyStream|grpc:Error {
        map<string|string[]> headers = {};
        SearchFilterInput message;
        if req is ContextSearchFilterInput {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("RentalService/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return {content: new stream<Property, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class Create_usersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUserCreateInput(UserCreateInput message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUserCreateInput(ContextUserCreateInput message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveUserCreateOutput() returns UserCreateOutput|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <UserCreateOutput>payload;
        }
    }

    isolated remote function receiveContextUserCreateOutput() returns ContextUserCreateOutput|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <UserCreateOutput>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class PropertyStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Property value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Property value;|} nextRecord = {value: <Property>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class RentalServiceUserCreateOutputCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUserCreateOutput(UserCreateOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUserCreateOutput(ContextUserCreateOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceRemovePropertyOutputCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendRemovePropertyOutput(RemovePropertyOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextRemovePropertyOutput(ContextRemovePropertyOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceSearchPropertyOutputCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendSearchPropertyOutput(SearchPropertyOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextSearchPropertyOutput(ContextSearchPropertyOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceTempBookingOutputCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendTempBookingOutput(TempBookingOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextTempBookingOutput(ContextTempBookingOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceBookingConfirmationOutputCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendBookingConfirmationOutput(BookingConfirmationOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextBookingConfirmationOutput(ContextBookingConfirmationOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceAddPropertyOutputCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddPropertyOutput(AddPropertyOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddPropertyOutput(ContextAddPropertyOutput response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServicePropertyCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendProperty(Property response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextProperty(ContextProperty response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextUserCreateInputStream record {|
    stream<UserCreateInput, error?> content;
    map<string|string[]> headers;
|};

public type ContextPropertyStream record {|
    stream<Property, error?> content;
    map<string|string[]> headers;
|};

public type ContextUserCreateOutput record {|
    UserCreateOutput content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyOutput record {|
    AddPropertyOutput content;
    map<string|string[]> headers;
|};

public type ContextSearchFilterInput record {|
    SearchFilterInput content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyInput record {|
    RemovePropertyInput content;
    map<string|string[]> headers;
|};

public type ContextBookingConfirmationOutput record {|
    BookingConfirmationOutput content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingRequest record {|
    ConfirmBookingRequest content;
    map<string|string[]> headers;
|};

public type ContextUserCreateInput record {|
    UserCreateInput content;
    map<string|string[]> headers;
|};

public type ContextSearchInput record {|
    SearchInput content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyInput record {|
    AddPropertyInput content;
    map<string|string[]> headers;
|};

public type ContextBookingRequest record {|
    BookingRequest content;
    map<string|string[]> headers;
|};

public type ContextTempBookingOutput record {|
    TempBookingOutput content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyOutput record {|
    SearchPropertyOutput content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyInput record {|
    UpdatePropertyInput content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyOutput record {|
    RemovePropertyOutput content;
    map<string|string[]> headers;
|};

public type ContextProperty record {|
    Property content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UserCreateOutput record {|
    int total_created = 0;
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type User record {|
    string user_id = "";
    string name = "";
    UserRole role = HOST;
    string email = "";
    string phone = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type AddPropertyOutput record {|
    Property property = {};
    string message = "";
    boolean success = false;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchFilterInput record {|
    string location = "";
    float min_price = 0.0;
    float max_price = 0.0;
    string property_type = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type RemovePropertyInput record {|
    string property_id = "";
    string host_region = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type BookingConfirmationOutput record {|
    string booking_id = "";
    string property_id = "";
    string guest_id = "";
    string check_in = "";
    string check_out = "";
    int nights = 0;
    float total_cost = 0.0;
    boolean confirmed = false;
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ConfirmBookingRequest record {|
    string temp_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UserCreateInput record {|
    string user_id = "";
    string name = "";
    UserRole role = HOST;
    string email = "";
    string phone = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchInput record {|
    string property_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type AddPropertyInput record {|
    string host_id = "";
    string name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string description = "";
    string[] amenities = [];
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type BookingRequest record {|
    string property_id = "";
    string guest_id = "";
    string check_in = "";
    string check_out = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type TempBookingOutput record {|
    string temp_id = "";
    string message = "";
    boolean success = false;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchPropertyOutput record {|
    Property property = {};
    boolean available = false;
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UpdatePropertyInput record {|
    string property_id = "";
    float price_per_night = 0.0;
    PropertyStatus status = AVAILABLE;
    string description = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type RemovePropertyOutput record {|
    Property[] remaining_properties = [];
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type Property record {|
    string property_id = "";
    string host_id = "";
    string name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    PropertyStatus status = AVAILABLE;
    string description = "";
    string[] amenities = [];
|};

public enum PropertyStatus {
    AVAILABLE, BOOKED, STATUS_REMOVED
}

public enum UserRole {
    HOST, GUEST
}
