import SwiftUI

/// Stop button shown in place of ``SendButton`` while a request is streaming.
///
/// Sized to ``ToolbarControlMetrics/circleDiameter`` so it matches the rest
/// of the action row.
public struct StopButton: View {

    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "stop.fill")
                .font(.system(size: ToolbarControlMetrics.symbolSize - 2,
                              weight: .semibold))
                .foregroundStyle(Color.primary)
                .frame(width: ToolbarControlMetrics.circleDiameter,
                       height: ToolbarControlMetrics.circleDiameter)
                .contentShape(Circle())
        }
        .buttonStyle(GlassCircleButtonStyle())
    }
}

#Preview("StopButton") {
    StopButton {}
        .padding()
}
