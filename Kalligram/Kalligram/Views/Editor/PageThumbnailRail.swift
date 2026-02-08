import SwiftUI

struct PageThumbnailRail: View {
    let pageCount: Int
    let currentPage: Int
    let onSelectPage: (Int) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: Spacing.sm) {
                    ForEach(1...max(1, pageCount), id: \.self) { page in
                        PageThumbnailView(
                            pageNumber: page,
                            isCurrentPage: page == currentPage
                        ) {
                            onSelectPage(page)
                        }
                        .id(page)
                    }
                }
                .padding(.vertical, Spacing.md)
                .padding(.horizontal, Spacing.sm)
            }
            .frame(width: 80)
            .background(ColorPalette.surfaceSecondary)
            .onChange(of: currentPage) { _, newPage in
                withAnimation(AnimationTokens.snappy) {
                    proxy.scrollTo(newPage, anchor: .center)
                }
            }
        }
    }
}
