import SwiftUI

/// Bar-graph waveform driven by normalized amplitude samples.
///
/// Renders one capsule bar per amplitude sample, scaled between `minBarHeight`
/// and `maxBarHeight` based on the sample value (0...1). Samples are expected
/// to be a sliding window of recent audio levels with the newest sample at
/// the end of the array.
public struct VoiceWaveform: View {

    private let amplitudes: [Float]
    private let barWidth: CGFloat
    private let spacing: CGFloat
    private let minBarHeight: CGFloat
    private let maxBarHeight: CGFloat

    public init(
        amplitudes: [Float],
        barWidth: CGFloat = 3,
        spacing: CGFloat = 3,
        minBarHeight: CGFloat = 4,
        maxBarHeight: CGFloat = 28
    ) {
        self.amplitudes = amplitudes
        self.barWidth = barWidth
        self.spacing = spacing
        self.minBarHeight = minBarHeight
        self.maxBarHeight = maxBarHeight
    }

    public var body: some View {
        GeometryReader { geo in
            let count = visibleBarCount(in: geo.size.width)
            let visible = trailing(amplitudes, count: count)

            HStack(alignment: .center, spacing: spacing) {
                ForEach(Array(visible.enumerated()), id: \.offset) { _, amp in
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: barWidth, height: height(for: amp))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: maxBarHeight)
        .accessibilityHidden(true)
    }

    private func visibleBarCount(in width: CGFloat) -> Int {
        guard width > 0 else { return 0 }
        let stride = barWidth + spacing
        return max(1, Int((width + spacing) / stride))
    }

    private func trailing(_ samples: [Float], count: Int) -> [Float] {
        guard samples.count > count else { return samples }
        return Array(samples.suffix(count))
    }

    private func height(for amp: Float) -> CGFloat {
        let clamped = max(0, min(1, CGFloat(amp)))
        return minBarHeight + (maxBarHeight - minBarHeight) * clamped
    }
}

#Preview("VoiceWaveform — pulsing") {
    @Previewable @State var amps: [Float] = (0..<60).map { _ in Float.random(in: 0.05...0.9) }

    VoiceWaveform(amplitudes: amps)
        .padding()
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 50_000_000)
                amps.append(Float.random(in: 0.05...0.95))
                if amps.count > 200 { amps.removeFirst(amps.count - 200) }
            }
        }
}
