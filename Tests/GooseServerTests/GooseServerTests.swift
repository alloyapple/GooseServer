import XCTest
@testable import GooseServer

final class GooseServerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(GooseServer().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
