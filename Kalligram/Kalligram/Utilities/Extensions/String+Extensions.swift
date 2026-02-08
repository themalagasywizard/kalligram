import Foundation

extension String {
    var wordCount: Int {
        split(whereSeparator: \.isWhitespace).count
    }

    var characterCountExcludingSpaces: Int {
        filter { !$0.isWhitespace }.count
    }

    func truncated(to maxLength: Int, trailing: String = "...") -> String {
        if count <= maxLength { return self }
        return String(prefix(maxLength - trailing.count)) + trailing
    }
}
