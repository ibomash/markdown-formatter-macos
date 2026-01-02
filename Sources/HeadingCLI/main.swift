import Foundation
import HeadingCore

struct CLIOptions {
    var inputPath: String?
    var baseLevel: Int?
    var inspect = false
    var debug = false
    var showHelp = false
    var showVersion = false
}

enum CLIError: Error {
    case invalidArguments(String)
    case inputFailure(String)
}

let versionString = "heading-cli 0.1.0"

func printUsage(to handle: FileHandle = .standardOutput) {
    let text = """
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
    write(text + "\n", to: handle)
}

func write(_ text: String, to handle: FileHandle) {
    if let data = text.data(using: .utf8) {
        handle.write(data)
    }
}

func parseArguments(_ arguments: [String]) throws -> CLIOptions {
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

func readInput(from path: String?) throws -> String {
    if let path = path, path != "-" {
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            throw CLIError.inputFailure("Unable to read input file: \(path)")
        }
    }
    let data = FileHandle.standardInput.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
}

func jsonData(from object: Any) throws -> Data {
    if #available(macOS 10.13, *) {
        return try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
    }
    return try JSONSerialization.data(withJSONObject: object, options: [])
}

func jsonValue<T>(_ value: T?) -> Any {
    value ?? NSNull()
}

func writeJSONLine(_ object: Any, to handle: FileHandle) {
    do {
        var data = try jsonData(from: object)
        data.append(0x0A)
        handle.write(data)
    } catch {
        write("Failed to encode JSON.\n", to: handle)
    }
}

func debugParseLine(_ result: HeadingParseResult) -> [String: Any] {
    [
        "event": "parse",
        "headings": result.headings.count,
        "minLevel": jsonValue(result.minLevel),
        "maxLevel": jsonValue(result.maxLevel)
    ]
}

func debugRebaseLine(baseLevel: Int, parseResult: HeadingParseResult, outputChanged: Bool) -> [String: Any] {
    let offset = parseResult.minLevel.map { baseLevel - $0 }
    return [
        "event": "rebase",
        "baseLevel": baseLevel,
        "offset": jsonValue(offset),
        "headings": parseResult.headings.count,
        "changed": outputChanged
    ]
}

func inspectJSON(from parseResult: HeadingParseResult) -> [String: Any] {
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

do {
    let args = Array(CommandLine.arguments.dropFirst())
    let options = try parseArguments(args)

    if options.showHelp {
        printUsage()
        exit(0)
    }

    if options.showVersion {
        write(versionString + "\n", to: .standardOutput)
        exit(0)
    }

    let input = try readInput(from: options.inputPath)
    let parseResult = parseHeadings(in: input)

    if options.debug {
        writeJSONLine(debugParseLine(parseResult), to: .standardError)
    }

    if options.inspect {
        writeJSONLine(inspectJSON(from: parseResult), to: .standardOutput)
        exit(0)
    }

    guard let baseLevel = options.baseLevel else {
        throw CLIError.invalidArguments("Missing required --base-level for rebase output.")
    }

    let output = rebaseHeadings(in: input, toBaseLevel: baseLevel)

    if options.debug {
        writeJSONLine(debugRebaseLine(baseLevel: baseLevel, parseResult: parseResult, outputChanged: output != input), to: .standardError)
    }

    write(output, to: .standardOutput)
} catch CLIError.invalidArguments(let message) {
    write("Error: \(message)\n", to: .standardError)
    printUsage(to: .standardError)
    exit(2)
} catch CLIError.inputFailure(let message) {
    write("Error: \(message)\n", to: .standardError)
    exit(3)
} catch {
    write("Error: \(error.localizedDescription)\n", to: .standardError)
    exit(1)
}
