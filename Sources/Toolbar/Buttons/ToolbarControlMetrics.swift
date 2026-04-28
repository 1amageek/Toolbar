import CoreGraphics

/// Standard sizing for circular controls inside a ``ToolbarContainer`` action
/// row.
///
/// Use these values when adding a custom control (e.g. a connected-folder
/// chip rendered as a glass circle) so it lines up with the built-in
/// ``SendButton``, ``StopButton``, ``VoiceButton``, and ``ToolbarMenuButton``.
///
/// macOS uses a smaller diameter than iOS / iPadOS because pointer-driven
/// hit-testing does not require the same target size as touch.
public enum ToolbarControlMetrics {

    /// Diameter of a glass-circle button in the action row.
    public static var circleDiameter: CGFloat {
        #if os(macOS)
        return 30
        #else
        return 42
        #endif
    }

    /// Default symbol point size inside a glass-circle button.
    public static var symbolSize: CGFloat {
        #if os(macOS)
        return 14
        #else
        return 18
        #endif
    }
}
