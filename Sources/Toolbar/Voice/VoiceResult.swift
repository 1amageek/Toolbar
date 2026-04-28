import Foundation

/// What a voice input session produced.
public enum VoiceResult: Sendable {
    /// The provider transcribed the audio to text.
    case text(String)
    /// The provider returned a recorded audio file.
    case audio(URL)
}
