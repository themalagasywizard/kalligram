# Kalligram PRD (AI-First Long-Form Editor for macOS)

## 1. Summary
Kalligram is an AI-first macOS editor for long-form writing: articles, academic papers, books, marketing copy, and reports. It blends premium word/PDF editor capabilities with contextual AI assistance, built around a fast, distraction-free writing experience, a powerful research workflow, and book-ready pagination to support future print output.

## 2. Goals
- Enable users to produce high-quality long-form content faster without sacrificing editorial control.
- Provide best-in-class writing, structuring, and research tools.
- Deliver a delightful macOS-native experience (performance, shortcuts, polish).
- Provide accurate pagination to visualize manuscript length and prepare for print-ready workflows.

## 3. Non-Goals
- Not a full desktop publishing tool (layout is advanced but not InDesign-level).
- Not a collaboration suite as deep as Google Docs (v1 can be async with comments).

## 4. Target Users
- Researchers and academics writing papers and theses.
- Authors writing fiction and nonfiction books.
- Journalists and content marketers.
- Knowledge workers assembling reports, briefs, proposals.

## 5. Product Principles
- AI as co-pilot, not autopilot: AI is optional and always transparent.
- Flow first: No UI clutter; power tools are context-aware.
- Design clarity: Visual hierarchy, minimal friction.
- Trust: Citations, data lineage, and provenance are visible.
- Print-aware: Pagination must be accurate and stable across modes.

## 6. Core UX Layout
- Left sidebar: Library, Projects, Research, Templates.
- Center: Editor canvas with smart margins and typography controls.
- Right sidebar: AI panel, Outline, Citations, Comments, Version history.
- Top bar: File actions, Export, View modes, AI actions.

## 7. Features and Full User Flows

### A. Document Creation and Structure
**Feature: Create documents, projects, and sections**
1. User opens app and sees Library with New Document and templates.
2. User selects template or blank document.
3. Project setup modal: title, type, target format (doc/PDF/LaTeX), word count goal.
4. App creates document with optional skeleton outline.
5. User enters writing mode.

**Feature: Outline view (chapters/sections/blocks)**
1. User opens Outline panel in right sidebar.
2. User adds section headings via + or Cmd+Enter.
3. Drag-and-drop sections to reorder.
4. Click section to jump in editor.
5. Outline updates automatically as headings change.

### B. Writing and Editing (Word-Class Features)
**Feature: Rich text formatting**
1. User selects text.
2. Floating toolbar appears (font, size, bold, list, quote, citations).
3. User applies styling; changes reflected in Outline.

**Feature: Page and layout controls**
1. User opens Layout panel.
2. Sets margins, paper size, line spacing, paragraph spacing.
3. Switches between Draft, Print, and Reader views.

**Feature: PDF import and editing**
1. User imports a PDF.
2. App extracts text into editable blocks.
3. User edits with tracked changes; export back to PDF.
4. App preserves layout fidelity and warns if structure changes.

### C. Pagination and Print-Ready Visualization
**Feature: True pagination view (book visualization)**
1. User opens View mode selector and chooses Paginated View.
2. App renders content into pages using current paper size, margins, fonts, and spacing.
3. Page thumbnails appear in a left rail; main editor shows full page spreads.
4. User navigates by page number or thumbnail.
5. Changes update pagination live and preserve stable layout between sessions.

**Feature: Page numbering and section breaks**
1. User opens Layout panel and enables Page Numbers.
2. User sets numbering style (Roman/Arabic) and start page.
3. User inserts section or chapter breaks.
4. Pagination recalculates with accurate page counts per section.
5. Export preview shows final pagination.

**Feature: Pagination lock for future print workflows**
1. User enables Pagination Lock in Layout.
2. App freezes page flow to prevent accidental reflow.
3. User edits within a page and receives warnings if changes cause overflow.
4. User can accept overflow to a new page or adjust layout.
5. App tracks deltas to maintain print-ready stability.

### D. AI Writing and Rewrite Tools
**Feature: AI inline rewrite**
1. User highlights sentence or paragraph.
2. Rewrite with AI appears in context menu.
3. User chooses tone or goal (clearer, formal, shorter, more persuasive).
4. AI returns 3 options with diff preview.
5. User selects one or merges into original.

**Feature: AI generation from prompt**
1. User clicks Generate in an empty block.
2. Input prompt: Write a paragraph on...
3. User sets tone, audience, length, citations.
4. AI inserts suggestion as ghost text.
5. User accepts, edits, or regenerates.

**Feature: AI expand or condense**
1. User selects section.
2. Chooses Expand or Condense.
3. AI provides adjusted version.
4. User toggles between original and AI output.

### E. Research and Smart Links
**Feature: AI-assisted research panel**
1. User opens Research sidebar.
2. Enters a question or topic.
3. AI returns summary plus sources (smart links).
4. User drags citations into the document.
5. Bibliography updates automatically.

**Feature: Smart links (inline citations + metadata)**
1. User highlights a claim.
2. Click Find sources.
3. AI suggests sources with reliability scores.
4. User approves; citation inserted.
5. Hover shows abstract, publish date, author.

### F. Knowledge Graph and Notes
**Feature: Research notes hub**
1. User opens Notes tab.
2. Clips references or ideas.
3. Tags notes by topic or chapter.
4. AI summarizes notes into draft structure.

### G. Collaboration and Review
**Feature: Comments and suggestions**
1. User highlights text and adds comment.
2. Comment appears in sidebar.
3. Resolve or reply.
4. Export with comments or stripped clean.

**Feature: Version history**
1. User opens History panel.
2. Timeline of snapshots and AI actions.
3. Restore or branch from any point.

### H. Export and Publishing
**Feature: Export to PDF, DOCX, Markdown, LaTeX, EPUB**
1. User clicks Export.
2. Chooses format and style preset.
3. App previews export (including pagination if enabled).
4. Download or share.

### I. Templates and Workflows
**Feature: Document templates**
1. User opens Templates panel.
2. Chooses academic paper, book, blog post, or report.
3. Template preloads structure and style.

### J. AI Safety and Transparency
**Feature: AI attribution and diff view**
1. AI suggests text; diff view shows changes.
2. User accepts or rejects.
3. AI outputs logged in AI Actions history.

### K. Accessibility and Focus
**Feature: Focus mode and reading mode**
1. User toggles Focus mode.
2. UI fades to minimal view.
3. Word count, timer, and AI tools hidden or optional.

## 8. System Requirements
- Offline-first with local database.
- Cloud sync with conflict resolution.
- Autosave with versioning.
- Optional local-only mode with encryption at rest.

## 9. MVP vs Pro (Suggested)
**MVP**
- Core editor, AI rewrite, outline, export, research panel, paginated view.

**Pro**
- PDF editing, citations, multi-project, collaboration, EPUB export, pagination lock.
