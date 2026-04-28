import Foundation

/// Lifecycle state of a voice input session.
public enum VoiceState: Sendable, Equatable {
    case idle
    case recording
    case transcribing
}
