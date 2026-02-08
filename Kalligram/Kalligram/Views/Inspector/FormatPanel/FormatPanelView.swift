import SwiftUI

struct FormatPanelView: View {
    @Bindable var document: Document

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Format")
                    .font(Typography.headline)
                    .foregroundStyle(ColorPalette.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)

            KDivider()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    sectionHeader("Print Layout")

                    VStack(alignment: .leading, spacing: Spacing.md) {
                        labeledRow("Trim Size") {
                            Picker("", selection: paperSizeBinding) {
                                ForEach(PaperSize.allCases.filter { $0 != .custom }, id: \.self) { size in
                                    Text(size.displayName).tag(size)
                                }
                            }
                            .labelsHidden()
                        }

                        Text(sizeDescription(for: document.paperSizeEnum))
                            .font(Typography.caption2)
                            .foregroundStyle(ColorPalette.textTertiary)
                    }

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Margins (inches)")
                            .font(Typography.caption1)
                            .foregroundStyle(ColorPalette.textSecondary)
                        LazyVGrid(columns: columns, spacing: Spacing.sm) {
                            numberField("Top", value: inchesBinding($document.marginTop))
                            numberField("Bottom", value: inchesBinding($document.marginBottom))
                            numberField("Left", value: inchesBinding($document.marginLeft))
                            numberField("Right", value: inchesBinding($document.marginRight))
                        }
                    }

                    KDivider()

                    sectionHeader("Typography")

                    VStack(alignment: .leading, spacing: Spacing.md) {
                        labeledRow("Body Font") {
                            Picker("", selection: $document.bodyFontName) {
                                ForEach(fontOptions, id: \.self) { fontName in
                                    Text(fontName).tag(fontName)
                                }
                            }
                            .labelsHidden()
                        }

                        labeledRow("Font Size") {
                            HStack(spacing: Spacing.sm) {
                                Stepper("", value: $document.bodyFontSize, in: 8...24, step: 0.5)
                                    .labelsHidden()
                                Text("\(document.bodyFontSize, specifier: "%.1f") pt")
                                    .font(Typography.caption1)
                                    .foregroundStyle(ColorPalette.textSecondary)
                            }
                        }
                    }

                    KDivider()

                    sectionHeader("Paragraph")

                    VStack(alignment: .leading, spacing: Spacing.md) {
                        labeledRow("Line Spacing") {
                            Picker("", selection: $document.lineSpacing) {
                                ForEach(lineSpacingOptions, id: \.self) { value in
                                    Text("\(value, specifier: "%.2g")").tag(value)
                                }
                            }
                            .labelsHidden()
                        }

                        labeledRow("Spacing Before") {
                            numberField("pt", value: $document.paragraphSpacingBefore, unit: "pt")
                        }

                        labeledRow("Spacing After") {
                            numberField("pt", value: $document.paragraphSpacing, unit: "pt")
                        }

                        labeledRow("First Line Indent") {
                            numberField("in", value: inchesBinding($document.firstLineIndent))
                        }

                        labeledRow("Alignment") {
                            Picker("", selection: bodyAlignmentBinding) {
                                ForEach(ParagraphAlignment.allCases, id: \.self) { alignment in
                                    Text(alignment.displayName).tag(alignment)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }

                        Toggle("Hyphenate Text", isOn: $document.hyphenationEnabled)
                            .font(Typography.bodySmall)
                    }

                    KDivider()

                    sectionHeader("Export")

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Toggle("Include Page Numbers", isOn: $document.includePageNumbers)
                            .font(Typography.bodySmall)
                        Toggle("Include Table of Contents", isOn: $document.includeTableOfContents)
                            .font(Typography.bodySmall)
                    }
                }
                .padding(Spacing.lg)
            }
        }
    }

    private var paperSizeBinding: Binding<PaperSize> {
        Binding(
            get: { document.paperSizeEnum },
            set: { document.paperSizeEnum = $0 }
        )
    }

    private var bodyAlignmentBinding: Binding<ParagraphAlignment> {
        Binding(
            get: { document.bodyAlignmentEnum },
            set: { document.bodyAlignmentEnum = $0 }
        )
    }

    private var fontOptions: [String] {
        let curated = [
            "Georgia",
            "Baskerville",
            "Garamond",
            "Palatino",
            "Times New Roman",
            "Hoefler Text",
            "Iowan Old Style"
        ]
        if curated.contains(document.bodyFontName) {
            return curated
        }
        return [document.bodyFontName] + curated
    }

    private var lineSpacingOptions: [Double] {
        [1.0, 1.1, 1.15, 1.2, 1.3, 1.5, 2.0]
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Typography.caption1)
            .fontWeight(.medium)
            .foregroundStyle(ColorPalette.textSecondary)
    }

    private func labeledRow<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(title)
                .font(Typography.bodySmall)
                .foregroundStyle(ColorPalette.textPrimary)
            Spacer()
            content()
        }
    }

    private func numberField(_ label: String, value: Binding<Double>, unit: String? = nil) -> some View {
        HStack(spacing: Spacing.xs) {
            TextField("", value: value, formatter: numberFormatter)
                .textFieldStyle(.roundedBorder)
                .font(Typography.bodySmall)
                .frame(width: 70)
            if let unit {
                Text(unit)
                    .font(Typography.caption2)
                    .foregroundStyle(ColorPalette.textTertiary)
            } else {
                Text(label)
                    .font(Typography.caption2)
                    .foregroundStyle(ColorPalette.textTertiary)
            }
        }
    }

    private func inchesBinding(_ points: Binding<Double>) -> Binding<Double> {
        Binding(
            get: { points.wrappedValue / 72 },
            set: { points.wrappedValue = max(0, $0 * 72) }
        )
    }

    private func sizeDescription(for paperSize: PaperSize) -> String {
        let width = paperSize.widthPoints / 72
        let height = paperSize.heightPoints / 72
        return String(format: "%.2f x %.2f in", width, height)
    }

}
