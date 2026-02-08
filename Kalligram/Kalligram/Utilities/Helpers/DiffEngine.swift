import Foundation

enum DiffChunkType {
    case unchanged
    case added
    case removed
}

struct DiffChunk: Identifiable {
    let id = UUID()
    let type: DiffChunkType
    let text: String
}

enum DiffEngine {
    static func diff(old: String, new: String) -> [DiffChunk] {
        let oldWords = old.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
        let newWords = new.split(separator: " ", omittingEmptySubsequences: false).map(String.init)

        let (oldLen, newLen) = (oldWords.count, newWords.count)

        // Simple LCS-based diff
        var dp = Array(repeating: Array(repeating: 0, count: newLen + 1), count: oldLen + 1)
        for i in 1...oldLen {
            for j in 1...newLen {
                if oldWords[i - 1] == newWords[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        // Backtrack
        var i = oldLen, j = newLen
        var result: [DiffChunk] = []
        while i > 0 || j > 0 {
            if i > 0 && j > 0 && oldWords[i - 1] == newWords[j - 1] {
                result.append(DiffChunk(type: .unchanged, text: oldWords[i - 1]))
                i -= 1; j -= 1
            } else if j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j]) {
                result.append(DiffChunk(type: .added, text: newWords[j - 1]))
                j -= 1
            } else if i > 0 {
                result.append(DiffChunk(type: .removed, text: oldWords[i - 1]))
                i -= 1
            }
        }

        // Merge consecutive chunks of the same type
        var merged: [DiffChunk] = []
        for chunk in result.reversed() {
            if let last = merged.last, last.type == chunk.type {
                merged[merged.count - 1] = DiffChunk(type: chunk.type, text: last.text + " " + chunk.text)
            } else {
                merged.append(chunk)
            }
        }

        return merged
    }
}
