import Foundation

/// A generic file attachment referenced by URL.
public struct FileAttachment: ToolbarAttachment {

    public let id: String
    public let url: URL

    public init(url: URL) {
        self.id = url.path
        self.url = url
    }

    public var displayName: String { url.lastPathComponent }
    public var icon: AttachmentIcon { .fileURL(url) }
}
