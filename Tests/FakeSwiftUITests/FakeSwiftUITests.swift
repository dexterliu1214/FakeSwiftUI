import XCTest
@testable import FakeSwiftUI

final class FakeSwiftUITests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FakeSwiftUI().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
