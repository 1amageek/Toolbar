import Foundation

/// Visual representation of an attachment in its chip.
public enum AttachmentIcon: Sendable, Hashable {
    /// SF Symbol name.
    case system(String)
    /// File URL — resolved to a system icon at render time.
    case fileURL(URL)
    /// Image URL — rendered as a thumbnail.
    case image(URL)
}
