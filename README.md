# Toolbar

A SwiftUI Composer kit for AI chat interfaces. iOS 26+ / iPadOS 26+ / macOS 26+.

Toolbar provides declarative primitives for modern AI input bars — multi-line text editing, file/path/image attachments, slash commands, voice input (provider-driven), and a Liquid Glass surface. There is no monolithic `Toolbar` view: you compose a `ToolbarContainer` from the parts you need.

## Requirements

- Swift 6.2+
- macOS 26+ / iOS 26+ / iPadOS 26+
- Xcode 26+

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/1amageek/Toolbar.git", branch: "main")
```

## Usage

```swift
import SwiftUI
import Toolbar

struct ChatView: View {
    @State private var text = ""
    @State private var height: CGFloat = 36
    @State private var isFocused = false
    @State private var attachments: [any ToolbarAttachment] = []
    @State private var isStreaming = false

    @State private var voiceState: VoiceState = .idle
    @State private var voiceAmplitudes: [Float] = []
    @State private var amplitudeSource: (any VoiceAmplitudeSource)? = nil

    var body: some View {
        ScrollView {
            // ... message list ...
        }
        .safeAreaInset(edge: .bottom) {
            ToolbarContainer {
                if !attachments.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(attachments, id: \.id) { attachment in
                                AttachmentChip(attachment: attachment) {
                                    remove(attachment)
                                }
                            }
                        }
                    }
                }

                HStack(alignment: .bottom, spacing: 8) {
                    ToolbarMenuButton {
                        Button("Add file...")  { pickFile() }
                        Button("Add image...") { pickImage() }
                    } label: {
                        Image(systemName: "plus")
                    }

                    ToolbarEditor(
                        text: $text,
                        contentHeight: $height,
                        isFocused: $isFocused,
                        placeholder: "Message..."
                    )
                    .frame(minHeight: 36, maxHeight: max(36, min(height, 220)))

                    if isStreaming {
                        StopButton(action: cancel)
                    } else if text.isEmpty {
                        VoiceButton(
                            provider: voiceProvider,
                            onResult: append,
                            onStateChange: { state in
                                withAnimation(.smooth(duration: 0.25)) {
                                    voiceState = state
                                }
                                amplitudeSource = (state == .recording)
                                    ? voiceProvider as? any VoiceAmplitudeSource
                                    : nil
                            }
                        )
                    } else {
                        SendButton(isEnabled: true, action: send)
                    }
                }
            }
            .accessory {
                switch voiceState {
                case .idle:
                    EmptyView()
                case .recording:
                    VoiceWaveform(amplitudes: voiceAmplitudes)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                case .transcribing:
                    TranscribingIndicator()
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
            .voiceAmplitudes(from: amplitudeSource, into: $voiceAmplitudes)
        }
    }
}
```

`ToolbarContainer` paints a single unified Liquid Glass slab and uses `GlassEffectContainer` internally so glass-circle buttons and the slash popup morph cohesively with the slab. Embed it via `.safeAreaInset(edge: .bottom)` on your message scroll view — never directly inside a `VStack`.

`.accessory { }` inserts a view above the composer content within the same Liquid Glass slab. Use it for ephemeral state strips: live waveforms during voice recording, "transcribing…" indicators, error banners, draft previews, suggestion chips, upload progress, etc. The library doesn't enumerate what goes there — anything that should sit inside the slab above the input row qualifies.

See `DESIGN.md` for architecture details.

## License

MIT — see `LICENSE`.
