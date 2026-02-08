import SwiftUI
import SwiftData

struct NewDocumentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.name) private var projects: [Project]
    @State private var vm = NewDocumentViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Document")
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
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.xxl)
            .padding(.bottom, Spacing.lg)

            KDivider()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xxl) {
                    // Template picker
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Choose a Template")
                            .font(Typography.headline)
                            .foregroundStyle(ColorPalette.textPrimary)

                        TemplateGalleryView(
                            templates: vm.builtInTemplates,
                            selectedIndex: $vm.selectedTemplateIndex
                        )
                    }

                    KDivider()

                    // Document details
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Document Details")
                            .font(Typography.headline)
                            .foregroundStyle(ColorPalette.textPrimary)

                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Title")
                                .font(Typography.caption1)
                                .foregroundStyle(ColorPalette.textSecondary)
                            TextField("Untitled Document", text: $vm.title)
                                .textFieldStyle(.roundedBorder)
                                .font(Typography.body)
                        }

                        if !projects.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Project (Optional)")
                                    .font(Typography.caption1)
                                    .foregroundStyle(ColorPalette.textSecondary)
                                Picker("", selection: $vm.selectedProjectID) {
                                    Text("None").tag(nil as UUID?)
                                    ForEach(projects, id: \.id) { project in
                                        Text(project.name).tag(project.id as UUID?)
                                    }
                                }
                                .labelsHidden()
                            }
                        }

                        // Advanced toggle
                        DisclosureGroup("Advanced Options", isExpanded: $vm.showAdvanced) {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                HStack(spacing: Spacing.lg) {
                                    VStack(alignment: .leading, spacing: Spacing.xs) {
                                        Text("Paper Size")
                                            .font(Typography.caption1)
                                            .foregroundStyle(ColorPalette.textSecondary)
                                        Picker("", selection: $vm.paperSize) {
                                            ForEach(PaperSize.allCases.filter { $0 != .custom }, id: \.self) { size in
                                                Text(size.displayName).tag(size)
                                            }
                                        }
                                        .labelsHidden()
                                        .frame(width: 150)
                                    }

                                    VStack(alignment: .leading, spacing: Spacing.xs) {
                                        Text("Line Spacing")
                                            .font(Typography.caption1)
                                            .foregroundStyle(ColorPalette.textSecondary)
                                        Picker("", selection: $vm.lineSpacing) {
                                            Text("1.0").tag(1.0)
                                            Text("1.15").tag(1.15)
                                            Text("1.5").tag(1.5)
                                            Text("2.0").tag(2.0)
                                        }
                                        .labelsHidden()
                                        .frame(width: 100)
                                    }
                                }

                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("Word Count Goal (Optional)")
                                        .font(Typography.caption1)
                                        .foregroundStyle(ColorPalette.textSecondary)
                                    TextField("e.g. 5000", text: $vm.wordCountGoal)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 150)
                                }
                            }
                            .padding(.top, Spacing.sm)
                        }
                        .font(Typography.bodySmall)
                        .foregroundStyle(ColorPalette.textSecondary)
                    }
                }
                .padding(.horizontal, Spacing.xxl)
                .padding(.vertical, Spacing.lg)
            }

            KDivider()

            // Actions
            HStack {
                Spacer()
                HStack(spacing: Spacing.md) {
                    KButton("Cancel", style: .secondary) {
                        dismiss()
                    }
                    KButton("Create", icon: SFSymbolTokens.newDocument) {
                        let doc = vm.createDocument(in: modelContext, projects: projects)
                        appViewModel.openDocument(doc, in: appState)
                        appState.isNewDocumentSheetPresented = false
                        dismiss()
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.vertical, Spacing.lg)
        }
        .frame(width: 560, height: 620)
        .background(ColorPalette.windowBackground)
    }
}
