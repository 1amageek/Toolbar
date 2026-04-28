import SwiftUI

/// Compact indicator shown in place of ``VoiceWaveform`` while a voice
/// provider finalizes its result after the user stops recording.
///
/// Matches the height of ``VoiceWaveform`` so the surrounding Liquid Glass
/// slab does not visibly resize when transitioning recording → transcribing.
public struct TranscribingIndicator: View {

    private let label: String

    public init(label: String = "Transcribing…") {
        self.label = label
    }

    public var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(height: 28)
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(label))
    }
}

#Preview("TranscribingIndicator") {
    TranscribingIndicator()
        .padding()
}
