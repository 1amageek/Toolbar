import Foundation

/// Pluggable voice input back-end.
///
/// Toolbar ships no implementation: clients pick their own engine (e.g.,
/// `Speech.framework`, `WhisperKit`, a remote ASR service) and conform a
/// MainActor-isolated `@Observable` class to this protocol.
@MainActor
public protocol VoiceInputProvider: AnyObject {

    /// Current lifecycle state. Read by ``Toolbar`` to drive the mic button.
    var state: VoiceState { get }

    /// Begin recording. Throws if permission is denied or capture cannot start.
    func startRecording() async throws

    /// Stop recording and return the produced ``VoiceResult``. The provider may
    /// transcribe synchronously or asynchronously before returning.
    func stopRecording() async throws -> VoiceResult

    /// Abort the current session and discard any captured material.
    func cancel() async
}
