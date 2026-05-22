import XCTest
import HeadingCLIKit

final class HeadingCLIKitTests: XCTestCase {
    func testInspectOutputsJSONSummary() throws {
        let input = "# Title\n\n## Section\n"
        let output = runCLI(arguments: ["--inspect"], stdin: input) { _ in
            XCTFail("Unexpected file read")
            return .failure(.inputFailure("Unexpected"))
        }

        XCTAssertEqual(output.exitCode, 0)
        XCTAssertTrue(output.stderr.isEmpty)

        let json = try parseJSON(output.stdout)
        XCTAssertEqual(json["minLevel"] as? Int, 1)
        XCTAssertEqual(json["maxLevel"] as? Int, 2)
        let headings = json["headings"] as? [[String: Any]] ?? []
        XCTAssertEqual(headings.count, 2)
        XCTAssertEqual(headings.first?["title"] as? String, "Title")
    }

    func testRebaseRequiresBaseLevel() {
        let output = runCLI(arguments: [], stdin: "# Title\n") { _ in
            XCTFail("Unexpected file read")
            return .failure(.inputFailure("Unexpected"))
        }

        XCTAssertEqual(output.exitCode, 2)
        XCTAssertTrue(output.stdout.isEmpty)
        XCTAssertTrue(output.stderr.contains("Missing required --base-level"))
    }

    func testRebaseOutputsTransformedText() {
        let output = runCLI(arguments: ["--base-level", "2"], stdin: "# Title\n") { _ in
            XCTFail("Unexpected file read")
            return .failure(.inputFailure("Unexpected"))
        }

        XCTAssertEqual(output.exitCode, 0)
        XCTAssertEqual(output.stdout, "## Title\n")
    }

    func testInputFileRead() {
        let output = runCLI(arguments: ["--input", "note.md", "--base-level", "3"], stdin: "") { path in
            XCTAssertEqual(path, "note.md")
            return .success("## Title\n")
        }

        XCTAssertEqual(output.exitCode, 0)
        XCTAssertEqual(output.stdout, "### Title\n")
    }

    func testInputFileReadFailure() {
        let output = runCLI(arguments: ["--input", "missing.md", "--base-level", "3"], stdin: "") { path in
            XCTAssertEqual(path, "missing.md")
            return .failure(.inputFailure("Unable to read input file: \(path)"))
        }

        XCTAssertEqual(output.exitCode, 3)
        XCTAssertTrue(output.stderr.contains("Unable to read input file: missing.md"))
    }

    func testDebugOutputsJSONLines() throws {
        let output = runCLI(arguments: ["--base-level", "2", "--debug"], stdin: "# Title\n") { _ in
            XCTFail("Unexpected file read")
            return .failure(.inputFailure("Unexpected"))
        }

        XCTAssertEqual(output.exitCode, 0)
        let lines = output.stderr.split(separator: "\n")
        XCTAssertEqual(lines.count, 2)

        let parseLine = try parseJSON(String(lines[0]))
        let rebaseLine = try parseJSON(String(lines[1]))

        XCTAssertEqual(parseLine["event"] as? String, "parse")
        XCTAssertEqual(rebaseLine["event"] as? String, "rebase")
    }

    func testHelpShowsUsage() {
        let output = runCLI(arguments: ["--help"], stdin: "") { _ in
            XCTFail("Unexpected file read")
            return .failure(.inputFailure("Unexpected"))
        }

        XCTAssertEqual(output.exitCode, 0)
        XCTAssertTrue(output.stdout.contains("Usage: heading-cli"))
    }

    private func parseJSON(_ string: String) throws -> [String: Any] {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8) ?? Data()
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return json as? [String: Any] ?? [:]
    }
}
