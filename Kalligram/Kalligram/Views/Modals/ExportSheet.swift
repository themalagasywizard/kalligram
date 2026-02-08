import SwiftUI
import AppKit

struct ExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var document: Document
    let attributedString: NSAttributedString?

    @State private var exportVM = ExportViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Export")
                    .font(Typography.display)
                    .foregroundStyle(ColorPalette.textPrimary)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(ColorPalette.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(Spacing.xxl)

            KDivider()

            // Content
            HStack(spacing: 0) {
                // Left: Format selection + options
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Format picker
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Format")
                            .font(Typography.caption1)
                            .fontWeight(.medium)
                            .foregroundStyle(ColorPalette.textSecondary)

                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Button {
                                exportVM.selectedFormat = format
                                updatePreview()
                            } label: {
                                HStack(spacing: Spacing.sm) {
                                    Image(systemName: format.iconName)
                                        .frame(width: 20)
                                        .foregroundStyle(
                                            exportVM.selectedFormat == format
                                                ? ColorPalette.accentBlue
                                                : ColorPalette.textTertiary
                                        )
                                    Text(format.displayName)
                                        .font(Typography.bodySmall)
                                        .foregroundStyle(ColorPalette.textPrimary)
                                    Spacer()
                                    Text(".\(format.fileExtension)")
                                        .font(Typography.caption2)
                                        .foregroundStyle(ColorPalette.textTertiary)
                                }
                                .padding(.vertical, Spacing.xs)
                                .padding(.horizontal, Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                                        .fill(exportVM.selectedFormat == format
                                              ? ColorPalette.accentBlue.opacity(0.08)
                                              : Color.clear)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    KDivider()

                    // Options
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Options")
                            .font(Typography.caption1)
                            .fontWeight(.medium)
                            .foregroundStyle(ColorPalette.textSecondary)

                        Toggle("Page Numbers", isOn: $exportVM.includePageNumbers)
                            .font(Typography.bodySmall)
                        Toggle("Table of Contents", isOn: $exportVM.includeTableOfContents)
                            .font(Typography.bodySmall)
                    }

                    Spacer()
                }
                .frame(width: 220)
                .padding(Spacing.xxl)

                KDivider(orientation: .vertical)

                // Right: Preview
                ExportPreviewPane(previewText: exportVM.previewText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            KDivider()

            // Footer
            HStack {
                // Filename
                HStack(spacing: Spacing.sm) {
                    Text("Filename:")
                        .font(Typography.bodySmall)
                        .foregroundStyle(ColorPalette.textSecondary)
                    TextField("Filename", text: $exportVM.filename)
                        .textFieldStyle(.roundedBorder)
                        .font(Typography.bodySmall)
                        .frame(width: 200)
                    Text(".\(exportVM.selectedFormat.fileExtension)")
                        .font(Typography.caption1)
                        .foregroundStyle(ColorPalette.textTertiary)
                }

                Spacer()

                if let error = exportVM.error {
                    Text(error)
                        .font(Typography.caption1)
                        .foregroundStyle(.red)
                }

                if exportVM.isExporting {
                    ProgressView()
                        .scaleEffect(0.8)
                }

                KButton("Cancel", style: .secondary) {
                    dismiss()
                }

                KButton("Export", icon: SFSymbolTokens.export, style: .primary) {
                    Task {
                        guard let attrString = formattedAttributedString() else { return }
                        let metadata = buildMetadata()
                        if let data = await exportVM.export(attributedString: attrString, metadata: metadata) {
                            exportVM.saveToFile(data: data)
                            dismiss()
                        }
                    }
                }
            }
            .padding(Spacing.xxl)
        }
        .frame(width: 700, height: 520)
        .onAppear {
            exportVM.filename = document.title
            exportVM.includePageNumbers = document.includePageNumbers
            exportVM.includeTableOfContents = document.includeTableOfContents
            updatePreview()
        }
        .onChange(of: exportVM.includePageNumbers) { _, newValue in
            document.includePageNumbers = newValue
        }
        .onChange(of: exportVM.includeTableOfContents) { _, newValue in
            document.includeTableOfContents = newValue
        }
    }

    private func updatePreview() {
        guard let attrString = formattedAttributedString() else { return }
        exportVM.updatePreview(attributedString: attrString, metadata: buildMetadata())
    }

    private func buildMetadata() -> ExportMetadata {
        ExportMetadata(
            title: document.title,
            author: "Author",
            paperSize: document.paperSizeEnum,
            margins: NSEdgeInsets(
                top: document.marginTop,
                left: document.marginLeft,
                bottom: document.marginBottom,
                right: document.marginRight
            ),
            lineSpacing: document.lineSpacing,
            includePageNumbers: exportVM.includePageNumbers,
            includeTableOfContents: exportVM.includeTableOfContents
        )
    }

    private func formattedAttributedString() -> NSAttributedString? {
        guard let attrString = attributedString else { return nil }
        return DocumentFormattingService.applyingBodyStyle(to: attrString, document: document)
    }
}
