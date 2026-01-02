import Foundation
import HeadingCLIKit

let inputData = FileHandle.standardInput.readDataToEndOfFile()
let stdinText = String(data: inputData, encoding: .utf8) ?? ""
let arguments = Array(CommandLine.arguments.dropFirst())

let output = runCLI(arguments: arguments, stdin: stdinText) { path in
    do {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        return .success(text)
    } catch {
        return .failure(.inputFailure("Unable to read input file: \(path)"))
    }
}

if !output.stdout.isEmpty {
    if let data = output.stdout.data(using: .utf8) {
        FileHandle.standardOutput.write(data)
    }
}

if !output.stderr.isEmpty {
    if let data = output.stderr.data(using: .utf8) {
        FileHandle.standardError.write(data)
    }
}

exit(Int32(output.exitCode))
