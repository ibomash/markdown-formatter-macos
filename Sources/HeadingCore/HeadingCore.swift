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

public func parseHeadings(in text: String) -> HeadingParseResult {
    return HeadingParseResult(headings: [], minLevel: nil, maxLevel: nil)
}

public func rebaseHeadings(in text: String, toBaseLevel baseLevel: Int, capLevel: Int = 6) -> String {
    return text
}
