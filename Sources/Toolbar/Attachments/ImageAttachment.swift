import Foundation

/// An image referenced by URL. The chip renders a thumbnail via `AsyncImage`.
public struct ImageAttachment: ToolbarAttachment {

    public let id: String
    public let url: URL

    public init(url: URL) {
        self.id = url.path
        self.url = url
    }

    public var displayName: String { url.lastPathComponent }
    public var icon: AttachmentIcon { .image(url) }
}
