import SwiftUI

struct TemplateGalleryView: View {
    let templates: [NewDocumentViewModel.TemplateInfo]
    @Binding var selectedIndex: Int?

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            ForEach(Array(templates.enumerated()), id: \.offset) { index, template in
                TemplateCardView(
                    name: template.name,
                    description: template.description,
                    icon: template.icon,
                    isSelected: selectedIndex == index
                )
                .onTapGesture {
                    withAnimation(AnimationTokens.snappy) {
                        selectedIndex = index
                    }
                }
            }
        }
    }
}
