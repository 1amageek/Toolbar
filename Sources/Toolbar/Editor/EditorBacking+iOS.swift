#if !os(macOS)
import SwiftUI
import UIKit

struct EditorBacking: UIViewRepresentable {

    @Binding var text: String
    @Binding var contentHeight: CGFloat
    @Binding var isFocused: Bool
    @Binding var hasMarkedText: Bool
    var rightInset: CGFloat
    var onCommandReturn: () -> Void
    var onKeyEvent: (EditorKey) -> Bool
    var onPasteAttachment: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> BackingTextView {
        let textView = BackingTextView()
        textView.delegate = context.coordinator
        textView.coordinator = context.coordinator
        textView.font = .preferredFont(forTextStyle: .body)
        textView.textColor = .label
        textView.tintColor = .label
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.alwaysBounceVertical = false
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        textView.textContainer.lineFragmentPadding = 4

        return textView
    }

    func updateUIView(_ textView: BackingTextView, context: Context) {
        context.coordinator.parent = self
        if text != context.coordinator.appliedText {
            let oldLength = (textView.text as NSString).length
            let newLength = (text as NSString).length
            let selectedRange = textView.selectedRange
            textView.text = text
            if selectedRange.location == oldLength {
                textView.selectedRange = NSRange(location: newLength, length: 0)
            } else {
                textView.selectedRange = NSRange(
                    location: min(selectedRange.location, newLength),
                    length: 0
                )
            }
            textView.scrollRangeToVisible(textView.selectedRange)
            context.coordinator.appliedText = text
        }
        textView.synchronizeFocus()
        context.coordinator.scheduleRecalcHeight(textView)
    }

    @MainActor
    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: EditorBacking
        var appliedText: String?
        private var pendingMarkedTextUpdate: Bool?
        private var markedTextUpdateTask: Task<Void, Never>?

        init(_ parent: EditorBacking) {
            self.parent = parent
            self.appliedText = nil
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
            setMarkedTextFromUIKit(false)
        }

        func textViewDidChange(_ textView: UITextView) {
            let newText = textView.text ?? ""
            appliedText = newText
            parent.text = newText
            setMarkedTextFromUIKit(textView.markedTextRange != nil)
            scheduleRecalcHeight(textView)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            setMarkedTextFromUIKit(textView.markedTextRange != nil)
        }

        func setMarkedTextFromUIKit(_ hasMarkedText: Bool) {
            guard parent.hasMarkedText != hasMarkedText else { return }
            pendingMarkedTextUpdate = hasMarkedText
            markedTextUpdateTask?.cancel()
            markedTextUpdateTask = Task { @MainActor [weak self] in
                await Task.yield()
                guard let self, !Task.isCancelled else { return }
                let nextValue = self.pendingMarkedTextUpdate ?? hasMarkedText
                self.pendingMarkedTextUpdate = nil
                guard self.parent.hasMarkedText != nextValue else { return }
                self.parent.hasMarkedText = nextValue
            }
        }

        func scheduleRecalcHeight(_ textView: UITextView) {
            Task { @MainActor [weak self, weak textView] in
                guard let self, let textView else { return }
                self.recalcHeight(textView)
            }
        }

        func recalcHeight(_ textView: UITextView) {
            let fitting = textView.sizeThatFits(
                CGSize(width: max(textView.bounds.width, 1), height: .greatestFiniteMagnitude)
            )
            let newHeight = ceil(fitting.height)
            if abs(parent.contentHeight - newHeight) > 0.5 {
                parent.contentHeight = newHeight
            }
        }
    }
}

final class BackingTextView: UITextView {

    weak var coordinator: EditorBacking.Coordinator?

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            coordinator?.parent.isFocused = true
        }
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            coordinator?.parent.isFocused = false
        }
        return result
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        synchronizeFocus()
    }

    func synchronizeFocus() {
        guard let coordinator else { return }
        if coordinator.parent.isFocused {
            guard !isFirstResponder, window != nil else { return }
            becomeFirstResponder()
        } else if isFirstResponder {
            resignFirstResponder()
        }
    }

    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(
                input: "\r",
                modifierFlags: .command,
                action: #selector(handleCommandReturn)
            ),
            UIKeyCommand(
                input: UIKeyCommand.inputUpArrow,
                modifierFlags: [],
                action: #selector(handleNavigationKey(_:))
            ),
            UIKeyCommand(
                input: UIKeyCommand.inputDownArrow,
                modifierFlags: [],
                action: #selector(handleNavigationKey(_:))
            ),
            UIKeyCommand(
                input: UIKeyCommand.inputEscape,
                modifierFlags: [],
                action: #selector(handleNavigationKey(_:))
            ),
            UIKeyCommand(
                input: "\t",
                modifierFlags: [],
                action: #selector(handleNavigationKey(_:))
            ),
        ]
    }

    @objc func handleCommandReturn() {
        coordinator?.parent.onCommandReturn()
    }

    @objc func handleNavigationKey(_ command: UIKeyCommand) {
        guard let input = command.input else { return }
        let key: EditorKey
        switch input {
        case UIKeyCommand.inputUpArrow:   key = .up
        case UIKeyCommand.inputDownArrow: key = .down
        case UIKeyCommand.inputEscape:    key = .escape
        case "\t":                        key = .tab
        default:                          key = .other
        }
        _ = coordinator?.parent.onKeyEvent(key)
    }

    override func paste(_ sender: Any?) {
        if let urls = UIPasteboard.general.urls, let url = urls.first {
            coordinator?.parent.onPasteAttachment(url)
            return
        }
        super.paste(sender)
    }
}
#endif
