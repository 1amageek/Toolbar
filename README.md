# Toolbar

A SwiftUI Liquid Glass composer kit for AI chat interfaces.

`Toolbar` provides the primitives modern AI input bars are built from — multi-line editor, file / image / path attachments, slash commands, voice input, and a unified Liquid Glass surface — and lets you compose them declaratively. There is no monolithic `Toolbar` view: you put what you need inside a `ToolbarContainer`.

## Requirements

| | |
|---|---|
| Swift | 6.2+ |
| Platforms | iOS 26+ / iPadOS 26+ / macOS 26+ |
| Xcode | 26+ |

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/1amageek/Toolbar.git", branch: "main")
```

Then add `Toolbar` to your target dependencies.

## Quick start

A minimal composer with a menu, editor, and adaptive trailing button (Send / Stop / Voice):

```swift
import SwiftUI
import Toolbar

struct ChatView: View {
    @State private var text = ""
    @State private var height: CGFloat = ToolbarControlMetrics.circleDiameter
    @State private var isFocused = false
    @State private var isStreaming = false

    var body: some View {
        ScrollView {
            messageList
        }
        .safeAreaInset(edge: .bottom) {
            ToolbarContainer {
                HStack(alignment: .bottom, spacing: 8) {
                    ToolbarMenuButton {
                        Button("File",   systemImage: "doc")   { pickFile() }
                        Button("Image",  systemImage: "photo") { pickImage() }
                        Button("Folder", systemImage: "folder"){ pickFolder() }
                    } label: {
                        Image(systemName: "plus")
                    }

                    ToolbarEditor(
                        text: $text,
                        contentHeight: $height,
                        isFocused: $isFocused,
                        placeholder: "Message..."
                    )
                    .frame(
                        minHeight: ToolbarControlMetrics.circleDiameter,
                        maxHeight: max(ToolbarControlMetrics.circleDiameter, min(height, 220))
                    )

                    if isStreaming {
                        StopButton(action: cancel)
                    } else {
                        SendButton(isEnabled: !text.isEmpty, action: send)
                    }
                }
            }
        }
    }
}
```

`ToolbarContainer` paints **one** continuous Liquid Glass slab and wraps its children in a `GlassEffectContainer`, so glass-circle buttons and the slash popup morph cohesively with the slab. Embed it via `.safeAreaInset(edge: .bottom)` on the message scroll view — never directly inside a `VStack`.

## Voice + accessory area

`.accessory { }` inserts a view above the composer content within the same slab. Use it for ephemeral state strips: live waveforms during recording, "transcribing…" indicators, error banners, draft previews, suggestion chips, upload progress.

```swift
@State private var voiceState: VoiceState = .idle
@State private var amplitudes: [Float] = []
@State private var amplitudeSource: (any VoiceAmplitudeSource)? = nil

ToolbarContainer {
    HStack(alignment: .bottom, spacing: 8) {
        // ... menu, editor ...

        if text.isEmpty {
            VoiceButton(
                provider: voiceProvider,
                onResult: { result in /* finalized text/audio */ },
                onStateChange: { state in
                    withAnimation(.smooth(duration: 0.25)) { voiceState = state }
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
        VoiceWaveform(amplitudes: amplitudes)
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
    case .transcribing:
        TranscribingIndicator()
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
}
.voiceAmplitudes(from: amplitudeSource, into: $amplitudes)
```

The `.transcribing` state exists so the accessory **stays visible** between `stopRecording()` and the final result — without it the bar would briefly collapse and reflow once the transcript arrives.

## Slash commands

Slash popup goes **inside** the container, so it shares the morph domain with the slab:

```swift
ToolbarContainer {
    if !matches.isEmpty {
        SlashCommandPopup(
            commands: matches,
            selectedIndex: selectedIndex,
            onSelect: commit
        )
    }

    HStack(alignment: .bottom, spacing: 8) {
        // ... editor with $text driving `matches` via SlashCommandProvider ...
    }
}
```

Implement `SlashCommandProvider` against your own command source, or use the bundled `StaticSlashCommandProvider` for fixed lists.

## Attachments

Three URL-backed concrete types (`FileAttachment`, `ImageAttachment`, `PathAttachment`) all conform to the `ToolbarAttachment` protocol. Render them as glass capsules with `AttachmentChip`:

```swift
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
```

For inline `[[marker]]` attachments rendered directly inside the editor text, conform to `InlineAttachmentRenderer`.

## Public surface

| Component | Role |
|---|---|
| `ToolbarContainer` | Liquid Glass slab + `GlassEffectContainer` morph domain |
| `.accessory { }` | Modifier inserting an ephemeral strip above the content |
| `ToolbarEditor` | Cross-platform multi-line editor (`NSTextView` / `UITextView` backed) |
| `ToolbarMenuButton` | Glass-circle menu styled to match other buttons |
| `SendButton` / `StopButton` | Trailing action buttons with shared metrics |
| `VoiceButton` | Mic ↔ stop, drives a `VoiceInputProvider` and emits `VoiceState` |
| `VoiceWaveform` | Bar-graph visualization fed by `VoiceAmplitudeSource` |
| `TranscribingIndicator` | Progress strip for the post-recording analysis state |
| `AttachmentChip` | Glass capsule chip for any `ToolbarAttachment` |
| `SlashCommandPopup` | Glass popup list of matches |
| `GlassCircleButtonStyle` | Re-usable circular Liquid Glass button style |
| `ToolbarControlMetrics` | Platform-tuned `circleDiameter` / `symbolSize` (30/14 macOS, 42/18 iOS) |

Protocols you implement: `VoiceInputProvider`, `VoiceAmplitudeSource`, `SlashCommandProvider`, `ToolbarAttachment`, `InlineAttachmentRenderer`.

## Design philosophy

- **Declarative composition** — no environment-modifier soup. The composer body is just SwiftUI views in an `HStack` / `VStack`.
- **One slab, one morph domain** — children that need glass (popup, capsule chips, circle buttons) share the container's `GlassEffectContainer` so shape transitions stay fluid.
- **Provider-driven I/O** — voice, slash commands, and inline attachment rendering are protocols. The library never talks to Whisper, Speech, OCR, or any concrete backend.
- **Cross-platform internals stay private** — `ToolbarEditor` is the only place AppKit / UIKit leaks, and that leak is sealed behind the public SwiftUI surface.

See [`DESIGN.md`](DESIGN.md) for the full architecture write-up.

## License

MIT — see [`LICENSE`](LICENSE).
