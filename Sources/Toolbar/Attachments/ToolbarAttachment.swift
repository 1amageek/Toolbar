import Foundation

/// A single piece of material the user wants to send alongside the message.
///
/// All built-in attachments are URL-based to keep the package free of platform
/// imaging frameworks. Adopters are free to ship custom attachment kinds (e.g.,
/// inline audio buffers, structured data) by implementing this protocol.
public protocol ToolbarAttachment: Sendable, Identifiable where ID == String {
    /// Stable identifier for diffing inside ``Toolbar``'s attachment strip.
    var id: String { get }
    /// Short, human-readable label used as the chip text.
    var displayName: String { get }
    /// Visual icon used by the chip.
    var icon: AttachmentIcon { get }
}
