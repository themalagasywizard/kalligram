import Foundation

enum Spacing {
    /// 4pt — tight: icon-to-label
    static let xs: CGFloat = 4
    /// 8pt — compact: list items, related elements
    static let sm: CGFloat = 8
    /// 12pt — default: form fields, list items
    static let md: CGFloat = 12
    /// 16pt — section: groups within a panel
    static let lg: CGFloat = 16
    /// 20pt — large: between form sections
    static let xl: CGFloat = 20
    /// 24pt — panel: padding inside panels/cards
    static let xxl: CGFloat = 24
    /// 32pt — major: between major sections
    static let xxxl: CGFloat = 32
    /// 40pt — canvas: editor vertical padding
    static let canvas: CGFloat = 40
    /// 48pt — page: vertical spacing between pages
    static let page: CGFloat = 48
    /// 64pt — hero: top-level spacing
    static let hero: CGFloat = 64
    /// 80pt — editor: horizontal padding in draft mode
    static let editor: CGFloat = 80
    /// 44pt — editor toolbar height
    static let editorToolbarHeight: CGFloat = 44
    /// 34pt — document tab bar height
    static let tabBarHeight: CGFloat = 34

    // MARK: - Corner Radii

    /// 6pt — buttons, badges
    static let radiusSmall: CGFloat = 6
    /// 8pt — cards, inputs
    static let radiusMedium: CGFloat = 8
    /// 10pt — floating toolbar
    static let radiusLarge: CGFloat = 10
    /// 12pt — modals, sheets
    static let radiusXL: CGFloat = 12

    // MARK: - Component Sizes

    static let sidebarRowHeight: CGFloat = 36
    static let sidebarRowHeightComfortable: CGFloat = 44
    static let toolbarButtonSize: CGFloat = 28
    static let floatingToolbarPaddingH: CGFloat = 8
    static let floatingToolbarPaddingV: CGFloat = 6

    // MARK: - Sidebar

    static let sidebarMinWidth: CGFloat = 220
    static let sidebarIdealWidth: CGFloat = 260
    static let sidebarMaxWidth: CGFloat = 300

    // MARK: - Inspector

    static let inspectorMinWidth: CGFloat = 260
    static let inspectorIdealWidth: CGFloat = 300
    static let inspectorMaxWidth: CGFloat = 360
}
