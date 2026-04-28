import Foundation

/// Platform-neutral key event delivered to ``Toolbar`` clients.
///
/// Hardware keyboards on iPadOS and macOS produce these events; on iOS soft
/// keyboards only ``return`` and ``other`` are observable in practice.
public enum EditorKey: Sendable, Equatable {
    case up
    case down
    case `return`
    case tab
    case escape
    case other
}
