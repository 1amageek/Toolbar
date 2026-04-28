import Foundation
import Testing
@testable import Toolbar

@Suite("Built-in attachments")
struct AttachmentTests {

    @Test("FileAttachment id and display name derive from URL")
    func fileAttachmentMetadata() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/report.pdf")
        let attachment = FileAttachment(url: url)
        #expect(attachment.id == "/Users/test/Documents/report.pdf")
        #expect(attachment.displayName == "report.pdf")

        if case .fileURL(let resolved) = attachment.icon {
            #expect(resolved == url)
        } else {
            Issue.record("Expected .fileURL icon")
        }
    }

    @Test("PathAttachment uses folder system icon")
    func pathAttachmentIcon() {
        let url = URL(fileURLWithPath: "/Users/test/Desktop")
        let attachment = PathAttachment(url: url)

        if case .system(let symbol) = attachment.icon {
            #expect(symbol == "folder.fill")
        } else {
            Issue.record("Expected .system icon")
        }
    }

    @Test("ImageAttachment uses image icon variant")
    func imageAttachmentIcon() {
        let url = URL(fileURLWithPath: "/Users/test/Pictures/cat.jpg")
        let attachment = ImageAttachment(url: url)

        if case .image(let resolved) = attachment.icon {
            #expect(resolved == url)
        } else {
            Issue.record("Expected .image icon")
        }
    }
}
