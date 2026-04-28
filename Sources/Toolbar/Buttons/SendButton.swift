import SwiftUI

/// Send button rendered as a Liquid Glass circle with an accent arrow.
///
/// Sized to ``ToolbarControlMetrics/circleDiameter`` so it lines up with the
/// other action-row controls. Pair with ``StopButton`` to swap visuals while
/// a request is streaming.
public struct SendButton: View {

    private let isEnabled: Bool
    private let action: () -> Void

    public init(isEnabled: Bool, action: @escaping () -> Void) {
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.system(size: ToolbarControlMetrics.symbolSize, weight: .semibold))
                .foregroundStyle(isEnabled ? Color.accentColor : Color.secondary)
                .frame(width: ToolbarControlMetrics.circleDiameter,
                       height: ToolbarControlMetrics.circleDiameter)
                .contentShape(Circle())
        }
        .buttonStyle(GlassCircleButtonStyle())
        .disabled(!isEnabled)
    }
}

#Preview("SendButton — enabled") {
    SendButton(isEnabled: true) {}
        .padding()
}

#Preview("SendButton — disabled") {
    SendButton(isEnabled: false) {}
        .padding()
}
