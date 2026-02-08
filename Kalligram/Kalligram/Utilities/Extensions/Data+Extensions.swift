import Foundation

extension Data {
    var formattedByteCount: String {
        ByteCountFormatter.string(fromByteCount: Int64(count), countStyle: .file)
    }
}
