import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Glass capsule rendering a single ``ToolbarAttachment`` with a remove button.
public struct AttachmentChip: View {

    private let attachment: any ToolbarAttachment
    private let onRemove: () -> Void

    @State private var isHovered = false

    public init(
        attachment: any ToolbarAttachment,
        onRemove: @escaping () -> Void
    ) {
        self.attachment = attachment
        self.onRemove = onRemove
    }

    public var body: some View {
        HStack(spacing: 6) {
            iconView
                .frame(width: 16, height: 16)

            Text(attachment.displayName)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
                .truncationMode(.middle)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .glassEffect(.regular, in: .capsule)
        .onHover { isHovered = $0 }
    }

    @ViewBuilder
    private var iconView: some View {
        switch attachment.icon {
        case .system(let name):
            Image(systemName: name)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)

        case .fileURL(let url):
            FileIconView(url: url)

        case .image(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                default:
                    Color.secondary.opacity(0.2)
                }
            }
            .clipShape(.rect(cornerRadius: 3))
        }
    }
}

private struct FileIconView: View {
    let url: URL

    var body: some View {
        #if os(macOS)
        Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
            .resizable()
            .scaledToFit()
        #else
        Image(systemName: "doc")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.secondary)
        #endif
    }
}

#Preview("AttachmentChip — file") {
    AttachmentChip(
        attachment: FileAttachment(url: URL(fileURLWithPath: "/etc/hosts"))
    ) {}
    .padding()
}

#Preview("AttachmentChip — folder") {
    AttachmentChip(
        attachment: PathAttachment(url: URL(fileURLWithPath: "/Users/Shared/Public"))
    ) {}
    .padding()
}

#Preview("AttachmentChip — image") {
    AttachmentChip(
        attachment: ImageAttachment(url: URL(fileURLWithPath: "/System/Library/Desktop Pictures/Solid Colors/Stone.png"))
    ) {}
    .padding()
}
