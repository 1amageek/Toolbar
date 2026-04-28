import SwiftUI

/// Cross-platform multi-line text editor used by ``ToolbarContainer`` adopters.
///
/// On macOS this wraps `NSTextView` inside an `NSScrollView`; on iOS / iPadOS
/// it wraps `UITextView`. The SwiftUI surface is identical on every platform.
///
/// `ToolbarEditor` is intentionally low-level: it exposes raw text + cursor
/// callbacks so adopters can layer slash-command parsing, voice transcript
/// insertion, or inline attachment markers on top.
public struct ToolbarEditor: View {

    @Binding private var text: String
    @Binding private var contentHeight: CGFloat
    @Binding private var isFocused: Bool

    private let placeholder: String
    private let rightInset: CGFloat
    private let onCommandReturn: () -> Void
    private let onKeyEvent: (EditorKey) -> Bool
    private let onPasteAttachment: (URL) -> Void

    public init(
        text: Binding<String>,
        contentHeight: Binding<CGFloat>,
        isFocused: Binding<Bool>,
        placeholder: String = "Message...",
        rightInset: CGFloat = 0,
        onCommandReturn: @escaping () -> Void = {},
        onKeyEvent: @escaping (EditorKey) -> Bool = { _ in false },
        onPasteAttachment: @escaping (URL) -> Void = { _ in }
    ) {
        self._text = text
        self._contentHeight = contentHeight
        self._isFocused = isFocused
        self.placeholder = placeholder
        self.rightInset = rightInset
        self.onCommandReturn = onCommandReturn
        self.onKeyEvent = onKeyEvent
        self.onPasteAttachment = onPasteAttachment
    }

    public var body: some View {
        EditorBacking(
            text: $text,
            contentHeight: $contentHeight,
            isFocused: $isFocused,
            rightInset: rightInset,
            onCommandReturn: onCommandReturn,
            onKeyEvent: onKeyEvent,
            onPasteAttachment: onPasteAttachment
        )
        .overlay(alignment: .topLeading) {
            if text.isEmpty && !isFocused {
                Text(placeholder)
                    .foregroundStyle(.placeholder)
                    .padding(.leading, 4)
                    .padding(.top, 6)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview("ToolbarEditor — empty") {
    @Previewable @State var text: String = ""
    @Previewable @State var height: CGFloat = 36
    @Previewable @State var focused: Bool = false

    ToolbarEditor(
        text: $text,
        contentHeight: $height,
        isFocused: $focused
    )
    .frame(minHeight: 36, maxHeight: max(36, min(height, 220)))
    .padding(12)
    .glassEffect(.regular, in: .rect(cornerRadius: 20))
    .padding()
}

#Preview("ToolbarEditor — multi-line") {
    @Previewable @State var text: String = "Line 1\nLine 2\nLine 3"
    @Previewable @State var height: CGFloat = 80
    @Previewable @State var focused: Bool = true

    ToolbarEditor(
        text: $text,
        contentHeight: $height,
        isFocused: $focused
    )
    .frame(minHeight: 36, maxHeight: max(36, min(height, 220)))
    .padding(12)
    .glassEffect(.regular, in: .rect(cornerRadius: 20))
    .padding()
}
