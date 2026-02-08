import Foundation

extension String {
    /// Inserts zero-width spaces after common URL separators to allow wrapping.
    var softWrappedForUI: String {
        let separators = ["/", "-", "_", ".", "?", "&", "=", ":", "|"]
        var output = self
        for separator in separators {
            output = output.replacingOccurrences(of: separator, with: separator + "\u{200B}")
        }
        return output
    }
}
