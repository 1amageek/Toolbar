import Foundation

/// A command invocable via the `/` prefix in the editor.
public struct SlashCommand: Identifiable, Sendable, Hashable {

    public let id: String
    public let name: String
    public let description: String
    /// SF Symbol displayed alongside the row.
    public let icon: String

    public init(
        id: String,
        name: String,
        description: String = "",
        icon: String = "command"
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
    }

    /// Case-insensitive match against the user's partial query.
    public func matches(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let lower = query.lowercased()
        return name.lowercased().hasPrefix(lower)
            || name.lowercased().contains(lower)
            || description.lowercased().contains(lower)
    }
}
