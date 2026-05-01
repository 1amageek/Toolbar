import SwiftUI

/// Unified Liquid Glass surface for an AI-composer toolbar.
///
/// `ToolbarContainer` paints **one** continuous Liquid Glass slab as its
/// background and wraps its children in a `GlassEffectContainer` so that any
/// child glass surfaces (`SlashCommandPopup`, `AttachmentChip`, glass-circle
/// buttons) morph together inside the same domain.
///
/// The container has two stacked regions:
///
/// - **accessory** — an optional view inserted *above* `content` within the
///   same slab. Use it for ephemeral state surfaces such as a live
///   ``VoiceWaveform`` while recording, a ``TranscribingIndicator`` after
///   stopping, an error banner, a draft preview, or inline suggestions.
///   Set it via the ``accessory(_:)`` modifier; defaults to nothing.
/// - **content** — the developer-supplied composer body (action row,
///   attachment chips, slash popup, etc.).
///
/// Layering:
///
/// ```
/// ToolbarContainer
///   └─ GlassEffectContainer        ← morph domain (no own glass)
///        └─ VStack { accessory; content }
///             .glassEffect(.regular, in: .rect(cornerRadius: 28))
///                                  ← unified slab (this is the visible bg)
/// ```
///
/// Children **must not** paint their own rect glass on top of the editor area
/// (it would double up). Glass-circle buttons (`SendButton`, `StopButton`,
/// `VoiceButton`, `ToolbarMenuButton`) are fine because their circle shape
/// morphs naturally with the slab.
///
/// ```swift
/// ToolbarContainer {
///     if !matches.isEmpty {
///         SlashCommandPopup(commands: matches, selectedIndex: idx, onSelect: select)
///     }
///     HStack(alignment: .bottom, spacing: 8) {
///         ToolbarMenuButton { ... } label: { ... }
///         ToolbarEditor(text: $text, ...)
///         VoiceButton(provider: provider, onResult: append)
///     }
/// }
/// .accessory {
///     switch voiceState {
///     case .recording:    VoiceWaveform(amplitudes: amps)
///     case .transcribing: TranscribingIndicator()
///     case .idle:         EmptyView()
///     }
/// }
/// ```
///
/// Embed in chat views via `.safeAreaInset(edge: .bottom)`.
public struct ToolbarContainer<Accessory: View, Content: View>: View {

    private let accessory: Accessory
    private let spacing: CGFloat
    private let content: Content

    public init(
        spacing: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) where Accessory == EmptyView {
        self.accessory = EmptyView()
        self.spacing = spacing
        self.content = content()
    }

    fileprivate init(
        accessory: Accessory,
        spacing: CGFloat,
        content: Content
    ) {
        self.accessory = accessory
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        GlassEffectContainer {
            slabContent
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: .rect(cornerRadius: 28))
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var slabContent: some View {
        if Accessory.self == EmptyView.self {
            content
        } else {
            VStack(alignment: .leading, spacing: spacing) {
                accessory
                content
            }
        }
    }
}

extension ToolbarContainer {

    /// Inserts a view above the composer content within the same Liquid Glass
    /// slab. Replaces the current accessory.
    ///
    /// The accessory is rendered inside the unified slab — it should be a
    /// flat view that fills width naturally (a waveform, a progress strip, a
    /// banner, a row of suggestion chips, etc.) rather than a card with its
    /// own glass background.
    ///
    /// Insertion / removal animations are the caller's responsibility:
    /// wrap the trigger in `withAnimation { ... }`, or attach `.transition`
    /// on the inner view.
    public func accessory<A: View>(
        @ViewBuilder _ build: () -> A
    ) -> ToolbarContainer<A, Content> {
        ToolbarContainer<A, Content>(
            accessory: build(),
            spacing: spacing,
            content: content
        )
    }
}

// MARK: - Preview scaffolding

private struct PreviewMessage: Identifiable {
    let id = UUID()
    let role: Role
    let text: String

    enum Role { case user, assistant }
}

private struct PreviewMessageBubble: View {
    let message: PreviewMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }

            Text(message.text)
                .font(.system(size: 14))
                .foregroundStyle(message.role == .user ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(message.role == .user ? Color.accentColor : Color.secondary.opacity(0.15))
                }
                .fixedSize(horizontal: false, vertical: true)

            if message.role == .assistant { Spacer(minLength: 40) }
        }
        .frame(
            maxWidth: .infinity,
            alignment: message.role == .user ? .trailing : .leading
        )
    }
}

private let previewConversation: [PreviewMessage] = [
    .init(role: .user, text: "こんにちは"),
    .init(role: .assistant, text: "こんにちは。今日はどんなことをお手伝いしましょうか？"),
]

private struct ChatPreviewScaffold<Toolbar: View>: View {

    @ViewBuilder let toolbar: () -> Toolbar

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(previewConversation) { message in
                    PreviewMessageBubble(message: message)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .safeAreaInset(edge: .bottom) {
            toolbar()
        }
        .background(.background)
    }
}

private struct PreviewEditorCard: View {
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var focused: Bool
    var placeholder: String = "Message..."

    var body: some View {
        let baseline = ToolbarControlMetrics.circleDiameter
        ToolbarEditor(
            text: $text,
            contentHeight: $height,
            isFocused: $focused,
            placeholder: placeholder
        )
        .frame(minHeight: baseline,
               maxHeight: max(baseline, min(height, 220)))
        .padding(.horizontal, 4)
    }
}

// MARK: - Previews

@MainActor
private final class PreviewVoiceProvider: VoiceInputProvider {
    var state: VoiceState = .idle
    func startRecording() async throws { state = .recording }
    func stopRecording() async throws -> VoiceResult {
        state = .transcribing
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        state = .idle
        return .text("preview transcript")
    }
    func cancel() async { state = .idle }
}

private final class PreviewAmplitudeSource: VoiceAmplitudeSource, @unchecked Sendable {
    private let stream: AsyncStream<Float>
    private let continuation: AsyncStream<Float>.Continuation
    private var task: Task<Void, Never>?

    init() {
        var c: AsyncStream<Float>.Continuation!
        self.stream = AsyncStream { c = $0 }
        self.continuation = c
        self.task = Task { [continuation] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 50_000_000)
                continuation.yield(Float.random(in: 0.05...0.95))
            }
        }
    }

    deinit {
        task?.cancel()
        continuation.finish()
    }

    func amplitudeStream() -> AsyncStream<Float> { stream }
}

@ViewBuilder @MainActor
private func TrailingButton(
    text: String,
    isStreaming: Bool,
    voiceProvider: any VoiceInputProvider,
    onSend: @escaping @MainActor () -> Void = {},
    onStop: @escaping @MainActor () -> Void = {},
    onVoiceState: @escaping (VoiceState) -> Void = { _ in }
) -> some View {
    if isStreaming {
        StopButton(action: onStop)
    } else if text.isEmpty {
        VoiceButton(
            provider: voiceProvider,
            onResult: { _ in },
            onStateChange: onVoiceState
        )
    } else {
        SendButton(isEnabled: true, action: onSend)
    }
}

@ViewBuilder @MainActor
private func VoiceAccessory(
    state: VoiceState,
    amplitudes: [Float]
) -> some View {
    switch state {
    case .idle:
        EmptyView()
    case .recording:
        VoiceWaveform(amplitudes: amplitudes)
            .frame(maxWidth: .infinity)
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
    case .transcribing:
        TranscribingIndicator()
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
}

#Preview("ChatView — empty (voice)") {
    @Previewable @State var text: String = ""
    @Previewable @State var height: CGFloat = 36
    @Previewable @State var focused: Bool = true
    @Previewable @State var amplitudes: [Float] = []
    @Previewable @State var source: PreviewAmplitudeSource? = nil
    @Previewable @State var voiceState: VoiceState = .idle

    ChatPreviewScaffold {
        ToolbarContainer {
            HStack(alignment: .bottom, spacing: 8) {
                ToolbarMenuButton {
                    Button("File",        systemImage: "doc")              {}
                    Button("Image",       systemImage: "photo")            {}
                    Button("Folder",      systemImage: "folder")           {}
                    Divider()
                    Button("Screenshot",  systemImage: "camera.viewfinder"){}
                    Button("Clipboard",   systemImage: "doc.on.clipboard") {}
                } label: {
                    Image(systemName: "plus")
                }

                PreviewEditorCard(text: $text, height: $height, focused: $focused)

                TrailingButton(
                    text: text,
                    isStreaming: false,
                    voiceProvider: PreviewVoiceProvider(),
                    onVoiceState: { state in
                        withAnimation(.smooth(duration: 0.25)) {
                            voiceState = state
                        }
                        switch state {
                        case .recording:                source = PreviewAmplitudeSource()
                        case .transcribing, .idle:      source = nil
                        }
                    }
                )
            }
        }
        .accessory {
            VoiceAccessory(state: voiceState, amplitudes: amplitudes)
        }
        .voiceAmplitudes(from: source, into: $amplitudes)
    }
}

#Preview("ChatView — composing (send)") {
    @Previewable @State var text: String = "ToolbarContainer に何を入れるかは"
    @Previewable @State var height: CGFloat = 36
    @Previewable @State var focused: Bool = true
    @Previewable @State var attachments: [PathAttachment] = [
        PathAttachment(url: URL(fileURLWithPath: "/Users/Shared/Public"))
    ]

    ChatPreviewScaffold {
        ToolbarContainer {
            if !attachments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(attachments) { attachment in
                            AttachmentChip(attachment: attachment) {
                                attachments.removeAll { $0.id == attachment.id }
                            }
                        }
                    }
                }
            }

            HStack(alignment: .bottom, spacing: 8) {
                ToolbarMenuButton {
                    Button("File",        systemImage: "doc")              {}
                    Button("Image",       systemImage: "photo")            {}
                    Button("Folder",      systemImage: "folder")           {}
                    Divider()
                    Button("Screenshot",  systemImage: "camera.viewfinder"){}
                    Button("Clipboard",   systemImage: "doc.on.clipboard") {}
                } label: {
                    Image(systemName: "plus")
                }

                PreviewEditorCard(text: $text, height: $height, focused: $focused)

                TrailingButton(
                    text: text,
                    isStreaming: false,
                    voiceProvider: PreviewVoiceProvider()
                )
            }
        }
    }
}

#Preview("ChatView — slash open") {
    @Previewable @State var text: String = "/me"
    @Previewable @State var height: CGFloat = 36
    @Previewable @State var focused: Bool = true
    @Previewable @State var selected: Int? = 0

    let commands: [SlashCommand] = [
        SlashCommand(id: "memory", name: "memory", description: "Search memory", icon: "brain"),
        SlashCommand(id: "members", name: "members", description: "List team members", icon: "person.2"),
    ]

    ChatPreviewScaffold {
        ToolbarContainer {
            SlashCommandPopup(
                commands: commands,
                selectedIndex: selected,
                onSelect: { _ in }
            )

            HStack(alignment: .bottom, spacing: 8) {
                ToolbarMenuButton {
                    Button("File",        systemImage: "doc")              {}
                    Button("Image",       systemImage: "photo")            {}
                    Button("Folder",      systemImage: "folder")           {}
                    Divider()
                    Button("Screenshot",  systemImage: "camera.viewfinder"){}
                    Button("Clipboard",   systemImage: "doc.on.clipboard") {}
                } label: {
                    Image(systemName: "plus")
                }

                PreviewEditorCard(text: $text, height: $height, focused: $focused)

                TrailingButton(
                    text: text,
                    isStreaming: false,
                    voiceProvider: PreviewVoiceProvider()
                )
            }
        }
    }
}

#Preview("ChatView — streaming (stop)") {
    @Previewable @State var text: String = ""
    @Previewable @State var height: CGFloat = 36
    @Previewable @State var focused: Bool = false

    ChatPreviewScaffold {
        ToolbarContainer {
            HStack(alignment: .bottom, spacing: 8) {
                ToolbarMenuButton {
                    Button("File",        systemImage: "doc")              {}
                    Button("Image",       systemImage: "photo")            {}
                    Button("Folder",      systemImage: "folder")           {}
                    Divider()
                    Button("Screenshot",  systemImage: "camera.viewfinder"){}
                    Button("Clipboard",   systemImage: "doc.on.clipboard") {}
                } label: {
                    Image(systemName: "plus")
                }

                PreviewEditorCard(
                    text: $text,
                    height: $height,
                    focused: $focused,
                    placeholder: "Generating reply..."
                )

                TrailingButton(
                    text: text,
                    isStreaming: true,
                    voiceProvider: PreviewVoiceProvider()
                )
            }
        }
    }
}

#Preview("ChatView — voice mode") {
    @Previewable @State var amplitudes: [Float] = (0..<80).map { _ in Float.random(in: 0.05...0.9) }
    @Previewable @State var text: String = "Liquid Glass の morph について説明して"
    @Previewable @State var height: CGFloat = 36
    @Previewable @State var focused: Bool = true

    ChatPreviewScaffold {
        ToolbarContainer {
            HStack(alignment: .bottom, spacing: 8) {
                ToolbarMenuButton {
                    Button("File",        systemImage: "doc")              {}
                    Button("Image",       systemImage: "photo")            {}
                    Button("Folder",      systemImage: "folder")           {}
                    Divider()
                    Button("Screenshot",  systemImage: "camera.viewfinder"){}
                    Button("Clipboard",   systemImage: "doc.on.clipboard") {}
                } label: {
                    Image(systemName: "plus")
                }

                PreviewEditorCard(text: $text, height: $height, focused: $focused)

                StopButton {}
            }
        }
        .accessory {
            VoiceWaveform(amplitudes: amplitudes)
                .frame(maxWidth: .infinity)
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 50_000_000)
                amplitudes.append(Float.random(in: 0.05...0.95))
                if amplitudes.count > 200 {
                    amplitudes.removeFirst(amplitudes.count - 200)
                }
            }
        }
    }
}

#Preview("ChatView — transcribing") {
    @Previewable @State var text: String = ""
    @Previewable @State var height: CGFloat = 36
    @Previewable @State var focused: Bool = true

    ChatPreviewScaffold {
        ToolbarContainer {
            HStack(alignment: .bottom, spacing: 8) {
                ToolbarMenuButton {
                    Button("File",        systemImage: "doc")              {}
                    Button("Image",       systemImage: "photo")            {}
                    Button("Folder",      systemImage: "folder")           {}
                    Divider()
                    Button("Screenshot",  systemImage: "camera.viewfinder"){}
                    Button("Clipboard",   systemImage: "doc.on.clipboard") {}
                } label: {
                    Image(systemName: "plus")
                }

                PreviewEditorCard(text: $text, height: $height, focused: $focused)

                StopButton {}
            }
        }
        .accessory {
            TranscribingIndicator()
        }
    }
}
