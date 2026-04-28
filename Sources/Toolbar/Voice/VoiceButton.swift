import SwiftUI

/// Mic / stop button driven by a ``VoiceInputProvider``.
///
/// The button manages its own recording state and dispatches lifecycle calls
/// to the supplied provider. Voice transcript or audio results are forwarded
/// via `onResult`; errors via `onError`. Recording state transitions are
/// reported via `onStateChange` so the parent (typically the chat view that
/// owns the ``ToolbarContainer/accessory(_:)`` strip) can update its UI in
/// sync.
public struct VoiceButton: View {

    private let provider: any VoiceInputProvider
    private let onResult: (VoiceResult) -> Void
    private let onError: (Error) -> Void
    private let onStateChange: (VoiceState) -> Void

    @State private var isRecording = false
    @State private var isBusy = false

    public init(
        provider: any VoiceInputProvider,
        onResult: @escaping (VoiceResult) -> Void,
        onError: @escaping (Error) -> Void = { _ in },
        onStateChange: @escaping (VoiceState) -> Void = { _ in }
    ) {
        self.provider = provider
        self.onResult = onResult
        self.onError = onError
        self.onStateChange = onStateChange
    }

    public var body: some View {
        Button {
            Task { await toggle() }
        } label: {
            Image(systemName: iconName)
                .font(.system(size: ToolbarControlMetrics.symbolSize, weight: .semibold))
                .frame(width: ToolbarControlMetrics.circleDiameter,
                       height: ToolbarControlMetrics.circleDiameter)
                .contentShape(Circle())
                .symbolEffect(.pulse, options: .repeating, isActive: isRecording)
        }
        .buttonStyle(GlassCircleButtonStyle())
        .disabled(isBusy)
    }

    private var iconName: String {
        isRecording ? "stop.fill" : "waveform"
    }

    private func toggle() async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }

        if isRecording {
            isRecording = false
            onStateChange(.transcribing)
            do {
                let result = try await provider.stopRecording()
                onStateChange(.idle)
                onResult(result)
            } catch {
                onStateChange(.idle)
                onError(error)
            }
        } else {
            do {
                try await provider.startRecording()
                isRecording = true
                onStateChange(.recording)
            } catch {
                onError(error)
            }
        }
    }
}

@MainActor
private final class PreviewVoiceProvider: VoiceInputProvider {
    var state: VoiceState = .idle
    func startRecording() async throws { state = .recording }
    func stopRecording() async throws -> VoiceResult {
        state = .idle
        return .text("preview transcript")
    }
    func cancel() async { state = .idle }
}

#Preview("VoiceButton") {
    VoiceButton(
        provider: PreviewVoiceProvider(),
        onResult: { _ in },
        onError: { _ in }
    )
    .padding()
}
