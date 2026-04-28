import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Renders inline attachment markers as pill-shaped `NSTextAttachment`s
/// inside the editor.
///
/// Adopters define a marker syntax such as `[[path:/Users/foo]]` and supply a
/// platform-specific image for each marker payload. The same renderer is used
/// for drop targets (URL → marker) and for round-tripping plain text ↔
/// attributed string.
public protocol InlineAttachmentRenderer: Sendable {

    /// Opening delimiter, e.g. `"[[path:"`.
    var markerPrefix: String { get }

    /// Closing delimiter, e.g. `"]]"`.
    var markerSuffix: String { get }

    /// Convert a dropped/dragged URL into a marker string.
    ///
    /// Return `nil` to fall through to the regular attachment array path.
    func marker(for url: URL) -> String?

    #if os(macOS)
    /// Build the attachment cell for a marker payload (the substring between
    /// `markerPrefix` and `markerSuffix`). Return `nil` if the payload is
    /// not understood — the marker is then left as plain text.
    @MainActor
    func makeAttachment(payload: String, font: NSFont) -> NSTextAttachment?
    #else
    @MainActor
    func makeAttachment(payload: String, font: UIFont) -> NSTextAttachment?
    #endif
}
