import SwiftUI

struct BranchFromSnapshotSheet: View {
    @Binding var title: String
    let onCancel: () -> Void
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Create Branch")
                    .font(Typography.headline)
                    .foregroundStyle(ColorPalette.textPrimary)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(ColorPalette.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(Spacing.lg)

            KDivider()

            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Branch Name")
                    .font(Typography.caption1)
                    .foregroundStyle(ColorPalette.textSecondary)
                TextField("New branch name", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .font(Typography.bodySmall)
            }
            .padding(Spacing.lg)

            KDivider()

            HStack {
                Spacer()
                KButton("Cancel", style: .secondary) {
                    onCancel()
                }
                KButton("Create", icon: SFSymbolTokens.branch, style: .primary) {
                    onCreate()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(Spacing.lg)
        }
        .frame(width: 420)
        .background(ColorPalette.windowBackground)
    }
}
