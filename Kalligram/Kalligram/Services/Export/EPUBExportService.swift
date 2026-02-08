import Foundation
import AppKit

final class EPUBExportService: ExportServiceProtocol {
    let format: ExportFormat = .epub

    func export(attributedString: NSAttributedString, metadata: ExportMetadata) throws -> Data {
        // Build EPUB as a ZIP archive
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("kalligram_epub_\(UUID().uuidString)")

        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        // mimetype (must be first, uncompressed)
        let mimetypePath = tempDir.appendingPathComponent("mimetype")
        try "application/epub+zip".write(to: mimetypePath, atomically: true, encoding: .utf8)

        // META-INF/container.xml
        let metaInf = tempDir.appendingPathComponent("META-INF")
        try FileManager.default.createDirectory(at: metaInf, withIntermediateDirectories: true)
        let containerXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
          <rootfiles>
            <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
          </rootfiles>
        </container>
        """
        try containerXML.write(to: metaInf.appendingPathComponent("container.xml"), atomically: true, encoding: .utf8)

        // OEBPS directory
        let oebps = tempDir.appendingPathComponent("OEBPS")
        try FileManager.default.createDirectory(at: oebps, withIntermediateDirectories: true)

        // content.opf
        let contentOPF = """
        <?xml version="1.0" encoding="UTF-8"?>
        <package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="bookid">
          <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
            <dc:title>\(escapeXML(metadata.title))</dc:title>
            <dc:creator>\(escapeXML(metadata.author))</dc:creator>
            <dc:language>en</dc:language>
            <dc:identifier id="bookid">urn:uuid:\(UUID().uuidString)</dc:identifier>
            <meta property="dcterms:modified">\(ISO8601DateFormatter().string(from: Date()))</meta>
          </metadata>
          <manifest>
            <item id="chapter1" href="chapter1.xhtml" media-type="application/xhtml+xml"/>
            <item id="style" href="style.css" media-type="text/css"/>
            <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
          </manifest>
          <spine>
            <itemref idref="chapter1"/>
          </spine>
        </package>
        """
        try contentOPF.write(to: oebps.appendingPathComponent("content.opf"), atomically: true, encoding: .utf8)

        // style.css
        let css = """
        body { font-family: Georgia, serif; font-size: 16px; line-height: 1.6; margin: 2em; }
        h1 { font-size: 1.8em; margin-bottom: 0.5em; }
        h2 { font-size: 1.4em; margin-bottom: 0.5em; }
        h3 { font-size: 1.2em; margin-bottom: 0.5em; }
        """
        try css.write(to: oebps.appendingPathComponent("style.css"), atomically: true, encoding: .utf8)

        // Convert attributed string to HTML
        let html = attributedStringToHTML(attributedString, title: metadata.title)
        try html.write(to: oebps.appendingPathComponent("chapter1.xhtml"), atomically: true, encoding: .utf8)

        // nav.xhtml
        let nav = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
        <head><title>Navigation</title></head>
        <body>
          <nav epub:type="toc">
            <ol><li><a href="chapter1.xhtml">\(escapeXML(metadata.title))</a></li></ol>
          </nav>
        </body>
        </html>
        """
        try nav.write(to: oebps.appendingPathComponent("nav.xhtml"), atomically: true, encoding: .utf8)

        // Create ZIP
        let zipURL = tempDir.appendingPathExtension("epub")
        var zipData: Data?

        // Use Process to zip
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        process.arguments = ["-rX", zipURL.path, "."]
        process.currentDirectoryURL = tempDir
        try process.run()
        process.waitUntilExit()

        if FileManager.default.fileExists(atPath: zipURL.path) {
            zipData = try Data(contentsOf: zipURL)
            try? FileManager.default.removeItem(at: zipURL)
        }

        guard let data = zipData else {
            throw ExportError.epubCreationFailed
        }
        return data
    }

    private func attributedStringToHTML(_ attrString: NSAttributedString, title: String) -> String {
        var html = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <title>\(escapeXML(title))</title>
          <link rel="stylesheet" type="text/css" href="style.css"/>
        </head>
        <body>

        """

        let string = attrString.string
        attrString.enumerateAttributes(in: NSRange(location: 0, length: attrString.length)) { attrs, range, _ in
            let text = escapeXML((string as NSString).substring(with: range))

            if let font = attrs[.font] as? NSFont {
                let size = font.pointSize
                if size >= 26 { html += "<h1>\(text)</h1>\n"; return }
                if size >= 20 { html += "<h2>\(text)</h2>\n"; return }
                if size >= 17 { html += "<h3>\(text)</h3>\n"; return }

                let traits = font.fontDescriptor.symbolicTraits
                var wrapped = text
                if traits.contains(.bold) { wrapped = "<strong>\(wrapped)</strong>" }
                if traits.contains(.italic) { wrapped = "<em>\(wrapped)</em>" }

                if let strikethrough = attrs[.strikethroughStyle] as? Int, strikethrough != 0 {
                    wrapped = "<del>\(wrapped)</del>"
                }

                html += wrapped
            } else {
                html += text
            }
        }

        html += "\n</body>\n</html>"
        return html
    }

    private func escapeXML(_ text: String) -> String {
        text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
