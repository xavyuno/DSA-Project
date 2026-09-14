// B2 + B3 - basic server logic tests
import ballerina/test;

@test:Config {}
function testDateValidation() {
    test:assertTrue(validDateRange("2026-10-10", "2026-10-13"));
    test:assertFalse(validDateRange("2026-10-13", "2026-10-10"));
    test:assertFalse(validDateRange("not-a-date", "2026-10-10"));
}

@test:Config {}
function testNightCount() returns error? {
    int nights = check countNights("2026-10-10", "2026-10-13");
    test:assertEquals(nights, 3);
}

@test:Config {}
function testOverlap() returns error? {
    test:assertTrue(check rangesOverlap("2026-10-10", "2026-10-13", "2026-10-12", "2026-10-15"));
    test:assertFalse(check rangesOverlap("2026-10-10", "2026-10-13", "2026-10-13", "2026-10-15"));
}
