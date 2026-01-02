public struct HeadingMatch: Equatable {
    public let lineIndex: Int
    public let columnIndex: Int
    public let level: Int
    public let rawLine: String
    public let title: String

    public init(lineIndex: Int, columnIndex: Int, level: Int, rawLine: String, title: String) {
        self.lineIndex = lineIndex
        self.columnIndex = columnIndex
        self.level = level
        self.rawLine = rawLine
        self.title = title
    }
}

public struct HeadingMatchSummary: Equatable {
    public let line: Int
    public let level: Int
    public let title: String

    public init(line: Int, level: Int, title: String) {
        self.line = line
        self.level = level
        self.title = title
    }
}

public struct HeadingParseResult: Equatable {
    public let headings: [HeadingMatch]
    public let minLevel: Int?
    public let maxLevel: Int?

    public init(headings: [HeadingMatch], minLevel: Int?, maxLevel: Int?) {
        self.headings = headings
        self.minLevel = minLevel
        self.maxLevel = maxLevel
    }
}

public struct HeadingInspectSummary: Equatable {
    public let minLevel: Int?
    public let maxLevel: Int?
    public let headings: [HeadingMatchSummary]

    public init(minLevel: Int?, maxLevel: Int?, headings: [HeadingMatchSummary]) {
        self.minLevel = minLevel
        self.maxLevel = maxLevel
        self.headings = headings
    }
}

public func inspectHeadings(in text: String) -> HeadingInspectSummary {
    let parseResult = parseHeadings(in: text)
    let summaries = parseResult.headings.map {
        HeadingMatchSummary(line: $0.lineIndex + 1, level: $0.level, title: $0.title)
    }
    return HeadingInspectSummary(
        minLevel: parseResult.minLevel,
        maxLevel: parseResult.maxLevel,
        headings: summaries
    )
}

public func parseHeadings(in text: String) -> HeadingParseResult {
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
    var headings: [HeadingMatch] = []
    var minLevel: Int?
    var maxLevel: Int?

    for (index, lineSub) in lines.enumerated() {
        var line = String(lineSub)
        if line.last == "\r" {
            line.removeLast()
        }
        var hashCount = 0
        var scanIndex = line.startIndex
        while scanIndex < line.endIndex, line[scanIndex] == "#" {
            hashCount += 1
            scanIndex = line.index(after: scanIndex)
        }
        guard hashCount > 0, hashCount <= 6 else { continue }
        guard scanIndex < line.endIndex, line[scanIndex].isWhitespace else { continue }
        let titleStart = line.index(after: scanIndex)
        let title = line[titleStart...].trimmingCharacters(in: .whitespaces)
        let match = HeadingMatch(
            lineIndex: index,
            columnIndex: 0,
            level: hashCount,
            rawLine: line,
            title: title
        )
        headings.append(match)
        minLevel = minLevel.map { min($0, hashCount) } ?? hashCount
        maxLevel = maxLevel.map { max($0, hashCount) } ?? hashCount
    }

    return HeadingParseResult(headings: headings, minLevel: minLevel, maxLevel: maxLevel)
}

public func rebaseHeadings(in text: String, toBaseLevel baseLevel: Int, capLevel: Int = 6) -> String {
    let safeBaseLevel = max(baseLevel, 1)
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
    let parseResult = parseHeadings(in: text)
    guard let minLevel = parseResult.minLevel, !parseResult.headings.isEmpty else {
        return text
    }
    let offset = safeBaseLevel - minLevel

    var rewritten = lines
    for heading in parseResult.headings {
        let newLevel = min(max(heading.level + offset, 1), capLevel)
        let hashes = String(repeating: "#", count: newLevel)
        let originalLine = heading.lineIndex < lines.count ? lines[heading.lineIndex] : ""
        let hasCarriageReturn = originalLine.last == "\r"
        let newLine = hasCarriageReturn ? "\(hashes) \(heading.title)\r" : "\(hashes) \(heading.title)"
        if heading.lineIndex < rewritten.count {
            rewritten[heading.lineIndex] = Substring(newLine)
        }
    }

    return rewritten.map(String.init).joined(separator: "\n")
}
