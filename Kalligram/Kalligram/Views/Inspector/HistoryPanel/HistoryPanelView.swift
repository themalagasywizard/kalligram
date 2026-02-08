import SwiftUI
import SwiftData

struct HistoryPanelView: View {
    let historyVM: VersionHistoryViewModel
    let document: Document?
    let onRestore: () -> Void

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Header
                HStack {
                    Image(systemName: SFSymbolTokens.history)
                        .foregroundStyle(ColorPalette.accentBlue)
                    Text("Version History")
                        .font(Typography.headline)
                        .foregroundStyle(ColorPalette.textPrimary)
                    Spacer()
                    if document != nil {
                        Button {
                            if let document {
                                historyVM.createManualSnapshot(for: document, modelContext: modelContext)
                            }
                        } label: {
                            HStack(spacing: 2) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 12))
                                Text("Snapshot")
                                    .font(Typography.caption2)
                            }
                            .foregroundStyle(ColorPalette.accentBlue)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if historyVM.versions.isEmpty {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: SFSymbolTokens.history)
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(ColorPalette.textTertiary.opacity(0.5))
                        Text("No version history yet")
                            .font(Typography.bodySmall)
                            .foregroundStyle(ColorPalette.textTertiary)
                        Text("Versions are created automatically on save and AI actions")
                            .font(Typography.caption1)
                            .foregroundStyle(ColorPalette.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.xxxl)
                } else {
                    // Timeline
                    ForEach(historyVM.versions, id: \.id) { version in
                        HistorySnapshotRow(
                            version: version,
                            isSelected: historyVM.selectedVersion?.id == version.id,
                            iconName: historyVM.triggerTypeIcon(version.triggerType),
                            onSelect: {
                                historyVM.selectedVersion = version
                            },
                            onRestore: {
                                if let document {
                                    historyVM.restore(version, to: document, modelContext: modelContext)
                                    onRestore()
                                }
                            }
                        )
                    }
                }
            }
            .padding(Spacing.lg)
        }
    }
}
