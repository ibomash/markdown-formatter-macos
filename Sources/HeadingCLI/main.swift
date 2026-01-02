import Foundation

let inputData = FileHandle.standardInput.readDataToEndOfFile()
if let input = String(data: inputData, encoding: .utf8), !input.isEmpty {
    if let outputData = input.data(using: .utf8) {
        FileHandle.standardOutput.write(outputData)
    }
}
