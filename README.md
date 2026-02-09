# Kalligram

Kalligram is a macOS‑native, AI‑first long‑form writing app with print‑aware pagination, research tools, and rich export options.

## Highlights
- Clean, distraction‑free editor with rich text formatting
- Paginated view with trim sizes, margins, and live page counts
- Research panel with summaries and sources
- Inline AI rewrite and generation tools
- Export to PDF, DOCX, Markdown, LaTeX, and EPUB
- Version history with snapshots and restore/branch workflows
- Templates for books, papers, reports, and blogs
- Document‑level formatting controls (paper size, typography, spacing)

## System Requirements
- macOS (Apple Silicon or Intel)
- Xcode 15+ (for building from source)

## Getting Started (Development)
1. Open the project in Xcode:
   - `Kalligram.xcodeproj`
2. Select the `Kalligram` scheme
3. Build and run (Cmd+R)

## Project Structure
- `Kalligram/`
  - `Views/` UI (Editor, Inspector panels, Modals)
  - `ViewModels/` app state and feature logic
  - `Models/` SwiftData models (Document, Project, Version, etc.)
  - `Services/` export, AI, document, version, and research services
  - `DesignSystem/` typography, spacing, colors, and components

## Key Features Overview
- **Editor:** Draft, Reader, Print, and Paginated modes
- **Formatting:** Headings, alignment, font sizing, and print layout controls
- **Research:** AI‑assisted summaries with sources and citations
- **History:** Snapshots with local previews, restore, and branch flows
- **Export:** PDF/DOCX/Markdown/LaTeX/EPUB with layout metadata

## Roadmap (High‑Level)
- Branch graph view for version history
- Diff/compare between snapshots
- Merge tools for alternate endings
- Advanced print presets (KDP/IngramSpark)
- Collaboration and comments enhancements

## Contributing
Contributions are welcome. Please open an issue or PR with:
- Clear description of the change
- Screenshots for UI updates
- Notes on testing steps

## License
This project is open source. MIT open source license.