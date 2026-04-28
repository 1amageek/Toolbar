import SwiftUI

/// Glass-circle ``Menu`` styled to match other ``ToolbarContainer`` controls.
///
/// This is purely cosmetic sugar: the body is a SwiftUI `Menu` whose label is
/// wrapped in a 42×42 circular glass surface. Adopters who want a different
/// affordance can use any `Menu`, `Button`, or custom view directly inside the
/// container's action row.
public struct ToolbarMenuButton<Label: View, Content: View>: View {

    @ViewBuilder private let content: () -> Content
    @ViewBuilder private let label: () -> Label

    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.content = content
        self.label = label
    }

    public var body: some View {
        Menu {
            content()
        } label: {
            label()
                .font(.system(size: ToolbarControlMetrics.symbolSize, weight: .semibold))
                .frame(width: ToolbarControlMetrics.circleDiameter,
                       height: ToolbarControlMetrics.circleDiameter)
                .contentShape(Circle())
                .glassEffect(.regular, in: .circle)
        }
        .menuIndicator(.hidden)
        .buttonStyle(.plain)
    }
}

#Preview("ToolbarMenuButton") {
    ToolbarMenuButton {
        Button("File",        systemImage: "doc")              {}
        Button("Image",       systemImage: "photo")            {}
        Button("Folder",      systemImage: "folder")           {}
        Divider()
        Button("Screenshot",  systemImage: "camera.viewfinder"){}
        Button("Clipboard",   systemImage: "doc.on.clipboard") {}
    } label: {
        Image(systemName: "plus")
    }
    .padding()
}
