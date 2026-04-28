import SwiftUI

/// Circular button style backed by a Liquid Glass material.
public struct GlassCircleButtonStyle: ButtonStyle {

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .glassEffect(.regular, in: .circle)
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(duration: 0.18, bounce: 0.2), value: configuration.isPressed)
    }
}

#Preview("GlassCircleButtonStyle") {
    HStack(spacing: 12) {
        Button {} label: {
            Image(systemName: "plus")
                .font(.system(size: ToolbarControlMetrics.symbolSize, weight: .semibold))
                .frame(width: ToolbarControlMetrics.circleDiameter,
                       height: ToolbarControlMetrics.circleDiameter)
        }
        .buttonStyle(GlassCircleButtonStyle())

        Button {} label: {
            Image(systemName: "waveform")
                .font(.system(size: ToolbarControlMetrics.symbolSize, weight: .semibold))
                .frame(width: ToolbarControlMetrics.circleDiameter,
                       height: ToolbarControlMetrics.circleDiameter)
        }
        .buttonStyle(GlassCircleButtonStyle())
    }
    .padding()
}
