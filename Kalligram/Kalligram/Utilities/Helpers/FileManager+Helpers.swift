import Foundation

extension FileManager {
    var kalligramDocumentsDirectory: URL {
        let urls = urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("Kalligram", isDirectory: true)
    }

    func ensureKalligramDirectoryExists() throws {
        let dir = kalligramDocumentsDirectory
        if !fileExists(atPath: dir.path) {
            try createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }
}
