import Foundation
import Testing
@testable import Toolbar

@Suite("Slash commands")
struct SlashCommandTests {

    @Test("matches is case-insensitive prefix or contains")
    func matching() {
        let command = SlashCommand(id: "rules", name: "Rules", description: "Edit rules")
        #expect(command.matches(""))
        #expect(command.matches("rul"))
        #expect(command.matches("RULE"))
        #expect(command.matches("dit"))
        #expect(!command.matches("zzz"))
    }

    @Test("StaticSlashCommandProvider filters by query")
    func staticProvider() async {
        let provider = StaticSlashCommandProvider([
            SlashCommand(id: "1", name: "Rules"),
            SlashCommand(id: "2", name: "Memory"),
            SlashCommand(id: "3", name: "Skills"),
        ])
        let filtered = await provider.commands(matching: "m")
        #expect(filtered.map(\.id) == ["2"])
    }
}
