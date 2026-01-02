import XCTest
@testable import HeadingCore

final class HeadingCoreTests: XCTestCase {
    func testParseEmptyReturnsNoHeadings() {
        let result = parseHeadings(in: "")
        XCTAssertTrue(result.headings.isEmpty)
        XCTAssertNil(result.minLevel)
        XCTAssertNil(result.maxLevel)
    }
}
