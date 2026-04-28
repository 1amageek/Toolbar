import Foundation

/// Source of slash commands for ``Toolbar``.
///
/// Adopters typically wire this up to their own command registry (e.g., a
/// skill manager or a plugin host). Use ``StaticSlashCommandProvider`` for
/// a fixed list known at compile time.
public protocol SlashCommandProvider: Sendable {
    /// Return commands matching the user's current `/` query.
    func commands(matching query: String) async -> [SlashCommand]
}

/// In-memory provider backed by a fixed array of commands.
public struct StaticSlashCommandProvider: SlashCommandProvider {

    public let commands: [SlashCommand]

    public init(_ commands: [SlashCommand]) {
        self.commands = commands
    }

    public func commands(matching query: String) async -> [SlashCommand] {
        commands.filter { $0.matches(query) }
    }
}
