import Foundation
import HeadingCore

public struct CLIOptions {
    public var inputPath: String?
    public var baseLevel: Int?
    public var inspect = false
    public var debug = false
    public var showHelp = false
    public var showVersion = false

    public init() {}
}

public enum CLIError: Error, Equatable {
    case invalidArguments(String)
    case inputFailure(String)
}

public struct CLIOutput: Equatable {
    public let stdout: String
    public let stderr: String
    public let exitCode: Int
}

public let versionString = "heading-cli 0.1.0"

public func usageText() -> String {
    """
    Usage: heading-cli [--input <path>|-] [--base-level <1-6>] [--inspect] [--debug]
           heading-cli --version
           heading-cli --help

    Options:
      --input <path>      Read Markdown from file (use "-" or omit for stdin).
      --base-level <1-6>  Base level for rebasing headings.
      --inspect           Emit JSON summary to stdout and exit.
      --debug             Emit JSON debug lines to stderr.
      --version           Show version and exit.
      --help              Show this help.
    """
}

public func parseArguments(_ arguments: [String]) throws -> CLIOptions {
    var options = CLIOptions()
    var index = 0
    while index < arguments.count {
        let arg = arguments[index]
        switch arg {
        case "--input":
            guard index + 1 < arguments.count else {
                throw CLIError.invalidArguments("Missing value for --input.")
            }
            options.inputPath = arguments[index + 1]
            index += 2
        case "--base-level":
            guard index + 1 < arguments.count else {
                throw CLIError.invalidArguments("Missing value for --base-level.")
            }
            let raw = arguments[index + 1]
            guard let level = Int(raw), (1...6).contains(level) else {
                throw CLIError.invalidArguments("Invalid base level: \(raw). Use 1-6.")
            }
            options.baseLevel = level
            index += 2
        case "--inspect":
            options.inspect = true
            index += 1
        case "--debug":
            options.debug = true
            index += 1
        case "--help", "-h":
            options.showHelp = true
            index += 1
        case "--version", "-v":
            options.showVersion = true
            index += 1
        default:
            throw CLIError.invalidArguments("Unknown argument: \(arg)")
        }
    }
    return options
}

public func runCLI(
    arguments: [String],
    stdin: String,
    readFile: (String) -> Result<String, CLIError>
) -> CLIOutput {
    do {
        let options = try parseArguments(arguments)

        if options.showHelp {
            return CLIOutput(stdout: usageText() + "\n", stderr: "", exitCode: 0)
        }

        if options.showVersion {
            return CLIOutput(stdout: versionString + "\n", stderr: "", exitCode: 0)
        }

        let input = try readInput(from: options.inputPath, stdin: stdin, readFile: readFile)
        let parseResult = parseHeadings(in: input)

        var stdout = ""
        var stderr = ""

        if options.debug {
            stderr.append(jsonLine(debugParseLine(parseResult)))
        }

        if options.inspect {
            stdout.append(jsonLine(inspectJSON(from: parseResult)))
            return CLIOutput(stdout: stdout, stderr: stderr, exitCode: 0)
        }

        guard let baseLevel = options.baseLevel else {
            throw CLIError.invalidArguments("Missing required --base-level for rebase output.")
        }

        let output = rebaseHeadings(in: input, toBaseLevel: baseLevel)

        if options.debug {
            let debugLine = debugRebaseLine(
                baseLevel: baseLevel,
                parseResult: parseResult,
                outputChanged: output != input
            )
            stderr.append(jsonLine(debugLine))
        }

        stdout.append(output)
        return CLIOutput(stdout: stdout, stderr: stderr, exitCode: 0)
    } catch let error as CLIError {
        switch error {
        case .invalidArguments(let message):
            let stderr = "Error: \(message)\n" + usageText() + "\n"
            return CLIOutput(stdout: "", stderr: stderr, exitCode: 2)
        case .inputFailure(let message):
            let stderr = "Error: \(message)\n"
            return CLIOutput(stdout: "", stderr: stderr, exitCode: 3)
        }
    } catch {
        let stderr = "Error: \(error.localizedDescription)\n"
        return CLIOutput(stdout: "", stderr: stderr, exitCode: 1)
    }
}

private func readInput(
    from path: String?,
    stdin: String,
    readFile: (String) -> Result<String, CLIError>
) throws -> String {
    if let path, path != "-" {
        switch readFile(path) {
        case .success(let contents):
            return contents
        case .failure(let error):
            throw error
        }
    }
    return stdin
}

private func jsonLine(_ object: Any) -> String {
    do {
        let data: Data
        if #available(macOS 10.13, *) {
            data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        } else {
            data = try JSONSerialization.data(withJSONObject: object, options: [])
        }
        return String(decoding: data, as: UTF8.self) + "\n"
    } catch {
        return "{\"error\":\"Failed to encode JSON.\"}\n"
    }
}

private func jsonValue<T>(_ value: T?) -> Any {
    value ?? NSNull()
}

private func debugParseLine(_ result: HeadingParseResult) -> [String: Any] {
    [
        "event": "parse",
        "headings": result.headings.count,
        "minLevel": jsonValue(result.minLevel),
        "maxLevel": jsonValue(result.maxLevel)
    ]
}

private func debugRebaseLine(
    baseLevel: Int,
    parseResult: HeadingParseResult,
    outputChanged: Bool
) -> [String: Any] {
    let offset = parseResult.minLevel.map { baseLevel - $0 }
    return [
        "event": "rebase",
        "baseLevel": baseLevel,
        "offset": jsonValue(offset),
        "headings": parseResult.headings.count,
        "changed": outputChanged
    ]
}

private func inspectJSON(from parseResult: HeadingParseResult) -> [String: Any] {
    let headings = parseResult.headings.map { heading in
        [
            "line": heading.lineIndex + 1,
            "level": heading.level,
            "title": heading.title
        ]
    }
    return [
        "minLevel": jsonValue(parseResult.minLevel),
        "maxLevel": jsonValue(parseResult.maxLevel),
        "headings": headings
    ]
}
