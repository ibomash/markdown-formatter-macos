import XCTest
@testable import HeadingCore

final class HeadingCoreTests: XCTestCase {
    func testParseEmptyReturnsNoHeadings() {
        let result = parseHeadings(in: "")
        XCTAssertTrue(result.headings.isEmpty)
        XCTAssertNil(result.minLevel)
        XCTAssertNil(result.maxLevel)
    }

    func testParseHeadingsDetectsLevelsAndTitles() {
        let input = "# Title\n\n## Section\nText\n### Subsection\n"
        let result = parseHeadings(in: input)
        XCTAssertEqual(result.headings.count, 3)
        XCTAssertEqual(result.minLevel, 1)
        XCTAssertEqual(result.maxLevel, 3)
        XCTAssertEqual(result.headings[0].title, "Title")
        XCTAssertEqual(result.headings[1].title, "Section")
        XCTAssertEqual(result.headings[2].title, "Subsection")
    }

    func testRebaseHeadingsClampsAtOne() {
        let input = "## Title\n### Section\n"
        let output = rebaseHeadings(in: input, toBaseLevel: 1)
        XCTAssertEqual(output, "# Title\n## Section\n")
        let clampedOutput = rebaseHeadings(in: input, toBaseLevel: 0)
        XCTAssertEqual(clampedOutput, "# Title\n## Section\n")
    }

    func testRebaseHeadingsCapsAtSix() {
        let input = "##### Near Max\n###### Max\n"
        let output = rebaseHeadings(in: input, toBaseLevel: 6)
        XCTAssertEqual(output, "###### Near Max\n###### Max\n")
    }

    func testInspectSummaryUsesOneBasedLineNumbers() {
        let input = "# Title\n\n## Section\n"
        let summary = inspectHeadings(in: input)
        XCTAssertEqual(summary.headings.first?.line, 1)
        XCTAssertEqual(summary.headings.last?.line, 3)
    }

    func testGoldenFixtures() throws {
        let fixtures = ["no-headings", "basic", "unicode", "max-level"]
        for name in fixtures {
            let input = try fixtureText(named: name)
            let expected = try fixtureText(named: "\(name).out")
            let baseLevel = baseLevelForFixture(name)
            let output = rebaseHeadings(in: input, toBaseLevel: baseLevel)
            XCTAssertEqual(output, expected, "Fixture mismatch for \\(name)")
        }
    }

    private func fixtureText(named name: String) throws -> String {
        let url = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "md", subdirectory: "Fixtures"))
        return try String(contentsOf: url, encoding: .utf8)
    }

    private func baseLevelForFixture(_ name: String) -> Int {
        switch name {
        case "basic":
            return 2
        case "unicode":
            return 4
        case "max-level":
            return 6
        default:
            return 3
        }
    }
}
