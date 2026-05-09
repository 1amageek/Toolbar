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
        textView.insertionPointColor = .labelColor
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
        if text != context.coordinator.appliedText {
            let oldLength = (textView.string as NSString).length
            let newLength = (text as NSString).length
            let selectedRange = textView.selectedRange()
            textView.string = text
            if selectedRange.location == oldLength {
                textView.setSelectedRange(NSRange(location: newLength, length: 0))
            } else {
                textView.setSelectedRange(NSRange(
                    location: min(selectedRange.location, newLength),
                    length: 0
                ))
            }
            textView.scrollRangeToVisible(textView.selectedRange())
            if textView.window?.firstResponder === textView {
                textView.refreshInsertionPoint()
            }
            context.coordinator.appliedText = text
        }
        textView.rightInset = rightInset
        textView.updateTextContainerWidth()
        textView.synchronizeFocus()
        context.coordinator.scheduleRecalcHeight()
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EditorBacking
        var appliedText: String?
        weak var textView: BackingTextView?
        private var pendingFocusUpdate: Bool?
        private var focusUpdateTask: Task<Void, Never>?
        private var heightUpdateTask: Task<Void, Never>?

        init(_ parent: EditorBacking) {
            self.parent = parent
            self.appliedText = nil
        }

        func textDidBeginEditing(_ notification: Notification) {
            setFocusFromAppKit(true)
        }

        func textDidEndEditing(_ notification: Notification) {
            setFocusFromAppKit(false)
        }

        func textDidChange(_ notification: Notification) {
            guard let textView else { return }
            appliedText = textView.string
            parent.text = textView.string
            recalcHeight()
        }

        func scheduleRecalcHeight() {
            heightUpdateTask?.cancel()
            heightUpdateTask = Task { @MainActor [weak self] in
                await Task.yield()
                guard !Task.isCancelled else { return }
                self?.recalcHeight()
            }
        }

        func setFocusFromAppKit(_ isFocused: Bool) {
            guard parent.isFocused != isFocused else { return }
            pendingFocusUpdate = isFocused
            focusUpdateTask?.cancel()
            focusUpdateTask = Task { @MainActor [weak self] in
                await Task.yield()
                guard let self, !Task.isCancelled else { return }
                let nextValue = self.pendingFocusUpdate ?? isFocused
                self.pendingFocusUpdate = nil
                guard self.parent.isFocused != nextValue else { return }
                self.parent.isFocused = nextValue
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

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        synchronizeFocus()
    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            coordinator?.setFocusFromAppKit(true)
            Task { @MainActor [weak self] in
                self?.refreshInsertionPoint()
            }
        }
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            coordinator?.setFocusFromAppKit(false)
        }
        return result
    }

    func synchronizeFocus() {
        guard let coordinator else { return }
        if coordinator.parent.isFocused {
            guard let window else { return }
            if window.firstResponder !== self {
                window.makeFirstResponder(self)
            }
            refreshInsertionPoint()
            Task { @MainActor [weak self] in
                self?.refreshInsertionPoint()
            }
        } else if window?.firstResponder === self {
            window?.makeFirstResponder(nil)
        }
    }

    func refreshInsertionPoint() {
        guard window?.firstResponder === self else { return }
        let textLength = (string as NSString).length
        let selectedRange = selectedRange()
        let visibleRange: NSRange
        if selectedRange.location + selectedRange.length > textLength {
            visibleRange = NSRange(location: textLength, length: 0)
            setSelectedRange(visibleRange)
        } else {
            visibleRange = selectedRange
        }
        if let layoutManager, let textContainer {
            layoutManager.ensureLayout(for: textContainer)
        }
        scrollRangeToVisible(visibleRange)
        updateInsertionPointStateAndRestartTimer(true)
        needsDisplay = true
    }

    func updateTextContainerWidth() {
        guard let textContainer else { return }
        let availableWidth = bounds.width - rightInset
        if availableWidth > 0, abs(textContainer.size.width - availableWidth) > 1 {
            textContainer.size.width = availableWidth
            refreshInsertionPoint()
        }
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateTextContainerWidth()
        refreshInsertionPoint()
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
