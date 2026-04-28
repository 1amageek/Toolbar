import Foundation

/// A folder reference. Distinct from ``FileAttachment`` so adopters can reason
/// about working directories versus arbitrary files.
public struct PathAttachment: ToolbarAttachment {

    public let id: String
    public let url: URL

    public init(url: URL) {
        self.id = url.path
        self.url = url
    }

    public var displayName: String { url.lastPathComponent }
    public var icon: AttachmentIcon { .system("folder.fill") }
}
