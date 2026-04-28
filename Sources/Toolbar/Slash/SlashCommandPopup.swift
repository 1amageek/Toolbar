import SwiftUI

/// Popup listing filtered ``SlashCommand``s above the editor.
///
/// Adopters typically place this as the first child of a ``ToolbarContainer``,
/// driven by their own state (filtered commands and the selected index).
public struct SlashCommandPopup: View {

    private let commands: [SlashCommand]
    private let selectedIndex: Int?
    private let onSelect: (SlashCommand) -> Void

    public init(
        commands: [SlashCommand],
        selectedIndex: Int?,
        onSelect: @escaping (SlashCommand) -> Void
    ) {
        self.commands = commands
        self.selectedIndex = selectedIndex
        self.onSelect = onSelect
    }

    public var body: some View {
        if !commands.isEmpty {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(commands.enumerated()), id: \.element.id) { index, command in
                            SlashCommandRow(
                                command: command,
                                isSelected: selectedIndex == index
                            ) {
                                onSelect(command)
                            }
                            .id(index)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxWidth: 320)
                .frame(maxHeight: 210)
                .glassEffect(.regular, in: .rect(cornerRadius: 12))
                .onChange(of: selectedIndex) { _, newValue in
                    guard let idx = newValue else { return }
                    withAnimation(.easeOut(duration: 0.1)) {
                        proxy.scrollTo(idx, anchor: .center)
                    }
                }
            }
        }
    }
}

private struct SlashCommandRow: View {

    let command: SlashCommand
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: command.icon)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                Text(command.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)

                if !command.description.isEmpty {
                    Text(command.description)
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background {
                if isSelected || isHovered {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.quaternary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

#Preview("SlashCommandPopup") {
    SlashCommandPopup(
        commands: [
            SlashCommand(id: "rules", name: "rules", description: "Edit rules", icon: "list.bullet"),
            SlashCommand(id: "memory", name: "memory", description: "Search memory", icon: "brain"),
            SlashCommand(id: "skills", name: "skills", description: "Browse skills", icon: "sparkles"),
        ],
        selectedIndex: 1,
        onSelect: { _ in }
    )
    .padding()
}
