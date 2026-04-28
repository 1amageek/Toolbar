import SwiftUI

/// A source of normalized audio amplitude samples used to drive
/// ``VoiceWaveform``.
///
/// Adopters publish a continuous stream of recent normalized samples
/// (`0...1`, newest last) — typically derived from an audio engine's tap
/// (peak / RMS / FFT band) at a stable cadence (e.g. 20–60 Hz). The protocol
/// is intentionally narrow: it only describes amplitude *visualization* data,
/// not the recording lifecycle (which is owned by ``VoiceInputProvider``). A
/// concrete type may conform to both.
///
/// ```swift
/// final class TapAmplitudeSource: VoiceAmplitudeSource {
///     private let continuation: AsyncStream<Float>.Continuation
///     private let stream: AsyncStream<Float>
///
///     init() {
///         var c: AsyncStream<Float>.Continuation!
///         self.stream = AsyncStream { c = $0 }
///         self.continuation = c
///     }
///
///     func amplitudeStream() -> AsyncStream<Float> { stream }
///
///     func push(_ sample: Float) {                         // called from the audio tap
///         continuation.yield(max(0, min(1, sample)))
///     }
///
///     func finish() { continuation.finish() }
/// }
/// ```
///
/// Wire to a SwiftUI view with ``SwiftUICore/View/voiceAmplitudes(from:into:capacity:)``:
///
/// ```swift
/// @State private var amplitudes: [Float] = []
/// @State private var source: TapAmplitudeSource? = nil
///
/// ToolbarContainer(mode: source == nil ? .composing : .voice(amplitudes: amplitudes)) {
///     ...
/// }
/// .voiceAmplitudes(from: source, into: $amplitudes)
/// ```
public protocol VoiceAmplitudeSource: AnyObject, Sendable {

    /// A stream of newly captured amplitude samples in the range `0...1`.
    ///
    /// - The stream produces one element per audio analysis tick.
    /// - The newest sample is the last yielded value.
    /// - The stream **finishes** when the source stops producing (e.g.
    ///   recording stops or is canceled). Subscribers should treat
    ///   completion as "no more samples" and not as an error.
    func amplitudeStream() -> AsyncStream<Float>
}

// MARK: - SwiftUI binding

extension View {

    /// Subscribes to `source` and pumps each yielded sample into `amplitudes`,
    /// keeping the array bounded to `capacity` (newest-last sliding window).
    ///
    /// The subscription's lifetime follows SwiftUI's `.task` semantics and is
    /// keyed off the source's object identity, so changing or clearing the
    /// source restarts the pipeline. Passing `nil` clears `amplitudes` and
    /// stops the pipeline.
    ///
    /// - Parameters:
    ///   - source: An optional ``VoiceAmplitudeSource``. `nil` halts and
    ///     clears the buffer.
    ///   - amplitudes: A binding to the sliding window the waveform reads.
    ///   - capacity: Maximum number of samples retained for rendering. The
    ///     default (`200`) suits a 20 Hz tap producing ~10 s of history at
    ///     typical bar widths.
    public func voiceAmplitudes(
        from source: (any VoiceAmplitudeSource)?,
        into amplitudes: Binding<[Float]>,
        capacity: Int = 200
    ) -> some View {
        self.task(id: source.map(ObjectIdentifier.init)) { @MainActor in
            amplitudes.wrappedValue.removeAll(keepingCapacity: true)
            guard let source else { return }
            for await sample in source.amplitudeStream() {
                var window = amplitudes.wrappedValue
                window.append(max(0, min(1, sample)))
                if window.count > capacity {
                    window.removeFirst(window.count - capacity)
                }
                amplitudes.wrappedValue = window
            }
        }
    }
}
