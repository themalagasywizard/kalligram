import Foundation

enum ViewMode: String, Codable, CaseIterable, Sendable {
    case draft
    case print
    case reader
    case paginated

    var displayName: String {
        switch self {
        case .draft: "Draft"
        case .print: "Print"
        case .reader: "Reader"
        case .paginated: "Paginated"
        }
    }

    var iconName: String {
        switch self {
        case .draft: SFSymbolTokens.draftMode
        case .print: SFSymbolTokens.printMode
        case .reader: SFSymbolTokens.readerMode
        case .paginated: SFSymbolTokens.paginatedMode
        }
    }
}
