#if os(macOS)
import SwiftUI
import AppKit
import Carbon.HIToolbox

struct EditorBacking: NSViewRepresentable {

    @Binding var text: String
    @Binding var contentHeight: CGFloat
    @Binding var isFocused: Bool
    var rightInset: CGFloat
    var onCommandReturn: () -> Void
    var onKeyEvent: (EditorKey) -> Bool
    var onPasteAttachment: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        if let scroller = scrollView.verticalScroller {
            scroller.controlSize = .mini
        }

        let textView = BackingTextView()
        textView.delegate = context.coordinator
        textView.coordinator = context.coordinator
        textView.isRichText = false
        textView.allowsUndo = true
        textView.font = .systemFont(ofSize: NSFont.systemFontSize)
        textView.textColor = .labelColor
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainerInset = NSSize(width: 0, height: 6)
        textView.textContainer?.lineFragmentPadding = 4
        textView.rightInset = rightInset
        textView.textContainer?.widthTracksTextView = true

        textView.registerForDraggedTypes([
            .fileURL,
            .URL,
            NSPasteboard.PasteboardType("NSFilenamesPboardType"),
        ])

        scrollView.documentView = textView
        context.coordinator.textView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? BackingTextView else { return }
        context.coordinator.parent = self
        if textView.string != text {
            textView.string = text
        }
        textView.rightInset = rightInset
        textView.updateTextContainerWidth()
        context.coordinator.scheduleRecalcHeight()
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EditorBacking
        weak var textView: BackingTextView?

        init(_ parent: EditorBacking) {
            self.parent = parent
        }

        func textDidBeginEditing(_ notification: Notification) {
            parent.isFocused = true
        }

        func textDidEndEditing(_ notification: Notification) {
            parent.isFocused = false
        }

        func textDidChange(_ notification: Notification) {
            guard let textView else { return }
            parent.text = textView.string
            recalcHeight()
        }

        func scheduleRecalcHeight() {
            DispatchQueue.main.async { [weak self] in
                self?.recalcHeight()
            }
        }

        func recalcHeight() {
            guard let textView,
                  let layoutManager = textView.layoutManager,
                  let textContainer = textView.textContainer else { return }
            layoutManager.ensureLayout(for: textContainer)
            let usedRect = layoutManager.usedRect(for: textContainer)
            let newHeight = ceil(usedRect.height) + textView.textContainerInset.height * 2
            if abs(parent.contentHeight - newHeight) > 0.5 {
                parent.contentHeight = newHeight
            }
        }

        func mapKey(_ event: NSEvent) -> EditorKey {
            switch Int(event.keyCode) {
            case kVK_UpArrow: return .up
            case kVK_DownArrow: return .down
            case kVK_Return: return .return
            case kVK_Tab: return .tab
            case kVK_Escape: return .escape
            default: return .other
            }
        }
    }
}

final class BackingTextView: NSTextView {

    weak var coordinator: EditorBacking.Coordinator?
    var rightInset: CGFloat = 0

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            DispatchQueue.main.async { [weak self] in
                self?.updateInsertionPointStateAndRestartTimer(true)
            }
        }
        return result
    }

    func updateTextContainerWidth() {
        guard let textContainer else { return }
        let availableWidth = bounds.width - rightInset
        if availableWidth > 0, abs(textContainer.size.width - availableWidth) > 1 {
            textContainer.size.width = availableWidth
        }
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateTextContainerWidth()
    }

    override func keyDown(with event: NSEvent) {
        // Cmd + Return -> send
        if event.keyCode == UInt16(kVK_Return), event.modifierFlags.contains(.command) {
            coordinator?.parent.onCommandReturn()
            return
        }
        if let coordinator {
            let key = coordinator.mapKey(event)
            if key != .other, coordinator.parent.onKeyEvent(key) {
                return
            }
        }
        super.keyDown(with: event)
    }

    override func insertTab(_ sender: Any?) {
        if coordinator?.parent.onKeyEvent(.tab) == true { return }
        super.insertTab(sender)
    }

    // MARK: - Drag & drop

    override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
        fileURL(from: sender.draggingPasteboard) != nil ? .copy : super.draggingEntered(sender)
    }

    override func draggingUpdated(_ sender: any NSDraggingInfo) -> NSDragOperation {
        fileURL(from: sender.draggingPasteboard) != nil ? .copy : super.draggingUpdated(sender)
    }

    override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        guard let url = fileURL(from: sender.draggingPasteboard) else {
            return super.performDragOperation(sender)
        }
        coordinator?.parent.onPasteAttachment(url)
        return true
    }

    private func fileURL(from pasteboard: NSPasteboard) -> URL? {
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL],
           let first = urls.first {
            return first
        }
        if let filenames = pasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String],
           let first = filenames.first {
            return URL(fileURLWithPath: first)
        }
        return nil
    }
}
#endif
