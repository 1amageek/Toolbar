#if !os(macOS)
import SwiftUI
import UIKit

struct EditorBacking: UIViewRepresentable {

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

    func makeUIView(context: Context) -> BackingTextView {
        let textView = BackingTextView()
        textView.delegate = context.coordinator
        textView.coordinator = context.coordinator
        textView.font = .preferredFont(forTextStyle: .body)
        textView.textColor = .label
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
        if textView.text != text {
            textView.text = text
        }
        context.coordinator.scheduleRecalcHeight(textView)
    }

    @MainActor
    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: EditorBacking

        init(_ parent: EditorBacking) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text ?? ""
            scheduleRecalcHeight(textView)
        }

        func scheduleRecalcHeight(_ textView: UITextView) {
            DispatchQueue.main.async { [weak self, weak textView] in
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
