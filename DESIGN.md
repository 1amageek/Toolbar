# Toolbar Design

AI Composer SwiftUI ライブラリの設計書。Bob の `MessageInputView` 周辺を抽出し、現代的な AI 入力バーとして汎用化する。

## 背景と再定義

旧 Toolbar (2017, UIKit) の責務は「複数アイテムを横に並べて高さを計算するコンテナ」だった。AI チャット時代の入力バーは責務が変質し、テキストに加えて画像・ファイル・音声・スラッシュコマンド・任意のカスタムアイコンを束ねて 1 リクエストとして送出する **Composer** が中核になった。

新 Toolbar は概念ごと作り直す。互換性は維持しない。

```
旧 Toolbar (2017)              新 Toolbar (2026)

責務:                          責務:
  複数 item を並べる             AI Composer の primitive 群を提供
  高さの計算                     開発者が宣言的に組み立てる
                                プラットフォーム差分は Editor のみ
本質: container                 本質: declarative composer kit
```

## Goals

- iOS 26+ / iPadOS 26+ / macOS 26+ で動作する SwiftUI Composer 部品群
- Liquid Glass 全面採用 (`glassEffect`, `GlassEffectContainer`, `glassEffectID`)
- **宣言的 API**: 開発者が `ToolbarContainer` の中身を自由に組み立てる
- 添付・音声・スラッシュコマンドを protocol で外部実装と接続
- 公開 API は SwiftUI のみ。内部の `NSViewRepresentable` / `UIViewRepresentable` は隠蔽
- 単一モジュール (`import Toolbar` で完結)

## Non-goals

- 旧 UIKit Toolbar との互換維持
- 音声処理 (Whisper / Apple Speech) の内蔵実装
- 画像処理 / OCR / カメラ撮影の内蔵
- macOS 25 以下 / iOS 25 以下のサポート
- 一体型 `Toolbar(text:onSend:)` View や `.toolbarMenu(...)` のような環境値ベース設定 API（**設計方針として採用しない**）

## Design philosophy: declarative composition

新 Toolbar は **monolithic な `Toolbar` View を提供しない**。代わりに `ToolbarContainer` (Liquid Glass の親 surface) のみを提供し、その中に何を入れるかは開発者が決める。横並びの action 行は標準の `HStack(alignment: .bottom, spacing: 8)` で組む。`SlashCommandPopup` / `AttachmentChip` / `ToolbarEditor` / `SendButton` / `StopButton` / `VoiceButton` / `ToolbarMenuButton` などはすべて public な独立コンポーネントで、自由に並べ替え・追加・差し替えができる。

```
旧設計案                                新設計
─────────────────────────────────       ─────────────────────────────
Toolbar(text:onSend:)                   ToolbarContainer {
  .toolbarMenu { ... } label: { ... }      SlashCommandPopup(...)
  .toolbarSlashProvider(...)               AttachmentStrip(...)
  .toolbarVoiceProvider(...)               HStack(alignment: .bottom, spacing: 8) {
  .toolbarAccessory { ... }                  ToolbarMenuButton { ... }
  .toolbarStyle(.liquidGlass)                ToolbarEditor(text: $text)
                                             SendButton(isEnabled: ...) { ... }
                                          }
                                       }
                                       .accessory {
                                          // ephemeral state strip:
                                          // VoiceWaveform / Transcribing /
                                          // banners / suggestions / etc.
                                       }

責務: モノリシック View が               責務: primitive を組み立てるのは
       全 slot を内包し environment        開発者。Library は部品と
       で挙動を構成する                    Liquid Glass surface のみ提供
```

宣言的アプローチを採用する理由:

1. **拡張性**: 新しい役割の slot (例: connected-folder chip, generate-image button) を追加するときに新しい environment modifier を生やす必要がない。`HStack` の中にビューを 1 つ足すだけで済む。
2. **一貫性**: `HStack` / `Group` / `NavigationStack` と同じ SwiftUI 流儀に従うので、初見の開発者でも構造が読める。
3. **環境結合の排除**: 旧設計では menu / voice / accessory / style がすべて environment 経由だったため、子 View で readable になる順序や上書き優先順位を覚える必要があった。declarative なら body から構造が見える。

## High-level architecture

```
+-----------------------------------------------------------+
|                Public API (SwiftUI)                        |
|                                                            |
|   ToolbarContainer { ... }.accessory { ... }               |
|   ToolbarEditor(text:contentHeight:isFocused:)             |
|   ToolbarMenuButton { ... } label: { ... }                 |
|   AttachmentChip(attachment:onRemove:)                     |
|   SlashCommandPopup(commands:selectedIndex:onSelect:)      |
|   VoiceButton(provider:onResult:onError:onStateChange:)    |
|   VoiceWaveform(amplitudes:)                               |
|   TranscribingIndicator(label:)                            |
|   SendButton(isEnabled:action:) / StopButton(action:)      |
|   GlassCircleButtonStyle                                   |
|                                                            |
|   View modifiers:                                          |
|     ToolbarContainer.accessory { ... }                     |
|     .voiceAmplitudes(from:into:capacity:)                  |
|                                                            |
|   Protocols:                                               |
|     ToolbarAttachment, AttachmentIcon                      |
|     SlashCommandProvider, SlashCommand                     |
|     VoiceInputProvider, VoiceState, VoiceResult            |
|     VoiceAmplitudeSource                                   |
|     InlineAttachmentRenderer                               |
+-----------------------------------------------------------+
                          |
       +------------------+-------------------+
       |    Cross-platform internals          |
       |                                      |
       |  EditorBacking                       |
       |    +-- AppKit (#if os(macOS))         |
       |    |     NSScrollView { NSTextView }  |
       |    +-- UIKit  (#if !os(macOS))        |
       |          UITextView                   |
       +--------------------------------------+
```

プラットフォーム分岐は `EditorBacking` のみ。それ以外はすべて純 SwiftUI で iOS / iPadOS / macOS 共通実装。

## Module structure

```
Toolbar/
  Package.swift                          // swift-tools-version: 6.2
                                         // platforms: [.macOS(.v26), .iOS(.v26)]

  Sources/Toolbar/
    ToolbarContainer.swift               // public, GlassEffectContainer + slab + .accessory modifier

    Editor/
      Editor.swift                       // public ToolbarEditor (SwiftUI facade)
      EditorBacking+macOS.swift          // internal NSTextView
      EditorBacking+iOS.swift            // internal UITextView
      EditorKey.swift                    // public EditorKey enum

    Attachments/
      ToolbarAttachment.swift            // public protocol
      AttachmentIcon.swift               // public enum
      AttachmentChip.swift               // public glass capsule view
      FileAttachment.swift               // public, URL-based
      PathAttachment.swift               // public, URL-based folder
      ImageAttachment.swift              // public, URL-based image

    Slash/
      SlashCommand.swift                 // public struct
      SlashCommandProvider.swift         // public protocol + StaticSlashCommandProvider
      SlashCommandPopup.swift            // public view

    Voice/
      VoiceInputProvider.swift           // public protocol
      VoiceAmplitudeSource.swift         // public protocol + .voiceAmplitudes modifier
      VoiceState.swift                   // public enum (.idle/.recording/.transcribing)
      VoiceResult.swift                  // public enum
      VoiceButton.swift                  // public view (with onStateChange)
      VoiceWaveform.swift                // public bar-graph visualization
      TranscribingIndicator.swift        // public progress view for .transcribing

    Menu/
      ToolbarMenu.swift                  // public ToolbarMenuButton

    Buttons/
      SendButton.swift                   // public
      StopButton.swift                   // public
      GlassCircleButton.swift            // public ButtonStyle

    Inline/
      InlineAttachmentRenderer.swift     // public protocol for [[marker]] support

  Tests/ToolbarTests/                    // Swift Testing
```

## Public API (canonical sample)

```swift
import SwiftUI
import Toolbar

struct ChatView: View {
    @State private var text = ""
    @State private var height: CGFloat = 36
    @State private var isFocused = false
    @State private var attachments: [any ToolbarAttachment] = []
    @State private var slashMatches: [SlashCommand] = []
    @State private var slashSelection: Int? = nil
    @State private var isStreaming = false

    // Voice state owned at the chat level. The accessory area shows a live
    // waveform during recording, and a "transcribing…" indicator while the
    // provider finalizes the result. The transcript itself flows into
    // `text` directly — the editor renders it like normal typed input.
    @State private var voiceAmplitudes: [Float] = []
    @State private var voiceState: VoiceState = .idle
    @State private var amplitudeSource: (any VoiceAmplitudeSource)? = nil

    let slashProvider: any SlashCommandProvider
    let voiceProvider: (any VoiceInputProvider)?

    var body: some View {
        ScrollView {
            messageList
        }
        .safeAreaInset(edge: .bottom) {
            ToolbarContainer {
                // Slash popup belongs INSIDE the container so it morphs
                // with the bar (Liquid Glass connects adjacent shapes).
                if !slashMatches.isEmpty {
                    SlashCommandPopup(
                        commands: slashMatches,
                        selectedIndex: slashSelection,
                        onSelect: commitSlash
                    )
                }

                if !attachments.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(attachments, id: \.id) { attachment in
                                AttachmentChip(attachment: attachment) {
                                    remove(attachment)
                                }
                            }
                        }
                    }
                }

                HStack(alignment: .bottom, spacing: 8) {
                    ToolbarMenuButton {
                        Button("Add file...")  { pickFile() }
                        Button("Add image...") { pickImage() }
                    } label: {
                        Image(systemName: "plus")
                    }

                    ToolbarEditor(
                        text: $text,
                        contentHeight: $height,
                        isFocused: $isFocused,
                        placeholder: "Message...",
                        onCommandReturn: send,
                        onKeyEvent: handleKey,
                        onPasteAttachment: addAttachment
                    )
                    .frame(minHeight: 36, maxHeight: max(36, min(height, 220)))

                    // App-specific accessory: just put a view here.
                    ConnectedFolderChip(folder: ...)

                    // Trailing slot: streaming → Stop, empty → Voice, otherwise → Send.
                    if isStreaming {
                        StopButton(action: cancel)
                    } else if text.isEmpty, let voiceProvider {
                        // While recording, the developer's pipeline pumps
                        // partial transcripts straight into `$text`, so the
                        // ToolbarEditor itself displays the recognized text.
                        VoiceButton(
                            provider: voiceProvider,
                            onResult: { _ in /* finalized text already in $text */ },
                            onStateChange: { state in
                                voiceState = state
                                // Wire the amplitude source for the waveform.
                                // The provider commonly conforms to both
                                // VoiceInputProvider and VoiceAmplitudeSource.
                                switch state {
                                case .recording:
                                    amplitudeSource = voiceProvider as? any VoiceAmplitudeSource
                                case .transcribing, .idle:
                                    amplitudeSource = nil
                                }
                            }
                        )
                    } else {
                        SendButton(isEnabled: !text.isEmpty, action: send)
                    }
                }
            }
            .accessory {
                switch voiceState {
                case .idle:
                    EmptyView()
                case .recording:
                    VoiceWaveform(amplitudes: voiceAmplitudes)
                        .frame(maxWidth: .infinity)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                case .transcribing:
                    TranscribingIndicator()
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
            .voiceAmplitudes(from: amplitudeSource, into: $voiceAmplitudes)
        }
    }
}
```

`onSend` payload struct (`ToolbarValue`) は **提供しない**。送信時に `text` / `attachments` / 直近の voice 結果を呼び出し側が直接組み立てる。

`ToolbarContainer` 自体は mode を持たない。**accessory** は `.accessory { ... }` modifier で差し込む空きスロットで、ライブラリ側がその中身を列挙しない。Wave / Transcribing 以外にもエラーバナー、ドラフトプレビュー、サジェストチップ列、ファイルアップロード進捗など "composer 本体の前に挟まる一時帯" すべてをここに置ける。

Voice の場合: `VoiceButton.onStateChange` が `.recording` / `.transcribing` / `.idle` を順に発火するので、これをそのまま `voiceState` に保存し、`.accessory { switch voiceState { ... } }` で振り分ける。amplitudes は `VoiceAmplitudeSource` を実装したストリーム源を `.voiceAmplitudes(from:into:)` modifier に渡すと自動で sliding window として `voiceAmplitudes` に流れる。

`.transcribing` 状態は **解析が終わるまで Wave を消さないため** に存在する。`stopRecording()` が完了する前に accessory を空に戻してしまうと、ユーザーには「停止 → 入力欄が空に戻った」ように見え、その後 transcript が遅れて流入するためチラつきが生じる。`.transcribing` の間は Wave の代わりに ``TranscribingIndicator`` (ProgressView + label) を表示し、結果を受け取ったタイミングで `.idle` に遷移して accessory が消える。

## Layout (default visual structure)

`ToolbarContainer` の内部は **accessory + content** の 2 段構成。`.accessory { }` を付けない場合は accessory が `EmptyView` で、見た目上は content だけが slab に乗る。

```
GlassEffectContainer {                  // morph domain
  VStack(alignment: .leading, spacing: 8) {

    accessory                           // ← .accessory { } で差し込まれた View
                                        //   省略時は EmptyView
                                        //   例: VoiceWaveform / TranscribingIndicator
                                        //       / error banner / draft preview /
                                        //       suggestion chips / upload progress

    content                             // ← 開発者が ToolbarContainer の trailing
                                        //   closure に書いた View 群
                                        //   (SlashCommandPopup, AttachmentChip,
                                        //    HStack { ToolbarMenuButton; ToolbarEditor;
                                        //              VoiceButton; SendButton }, ...)
  }
  .padding(.horizontal, 8)
  .padding(.vertical, 8)
  .glassEffect(.regular, in: .rect(cornerRadius: 28))   // unified slab
}
```

accessory は **slab の中** に同居するので、波形やインジケータが Liquid Glass の上に乗っているように見える。`content` 側のインスタンスは accessory の有無に関係なく **同じツリーがマウントされ続ける** ので、focus / cursor / 入力中テキストが保たれる。

### Accessory area: ephemeral state strip

accessory area は "composer 本体の前に一時的に乗る帯" を担う汎用スロット。voice 入力の Wave / 解析中インジケータが代表例だが、library が用途を列挙しない:

| 用途例 | 表示 view |
|---|---|
| 録音中 | ``VoiceWaveform`` |
| 解析中 | ``TranscribingIndicator`` |
| エラー | (呼び出し側) banner View |
| ドラフト | (呼び出し側) preview View |
| 提案 | (呼び出し側) suggestion chips |
| アップロード進捗 | (呼び出し側) progress strip |

呼び出し側が `.accessory { switch state { ... } }` で振り分ける。accessory の差し替えアニメーションは呼び出し側責任 — `withAnimation { state = ... }` でトリガし、各分岐の View に `.transition(.opacity.combined(with: .scale(0.96)))` を付ける。Container 側は accessory に対する自動アニメーションを持たない (汎用なので何が出るか知らない)。

### Voice transcript

transcript は accessory ではなく `ToolbarEditor.$text` 越しに普段通り編集領域に描画される。別 `Text` を生やす必要がなく、フォントサイズも editor のものに揃う。

`ToolbarContainer` は **1 枚の統一 Liquid Glass slab** を背景として描画する。`GlassEffectContainer` は morph domain として機能し、popup や glass circle ボタンなど "自前の `.glassEffect` を持つ子" は slab と同じドメイン内で連結 (morph) するため、popup 出現や send→stop 切り替えの形状アニメーションが滑らかに繋がる。

`ToolbarEditor` は自前の `.glassEffect(...)` を **持たない**。slab の上にプレーンに乗る。Editor を独自のガラスカード化したい場合は呼び出し側で `.glassEffect(.regular, in: .rect(cornerRadius: 22))` を付けることはできるが、デフォルトでは二重ガラス (slab + editor card) を避けるためプレーンにする。glass-circle 系のボタン (`SendButton` / `StopButton` / `VoiceButton` / `ToolbarMenuButton`) は円形なので slab 上に乗っても自然に morph する。

## Embedding pattern: `safeAreaInset`

`ToolbarContainer` はチャット View の `ScrollView` に対して `.safeAreaInset(edge: .bottom)` で配置する。`VStack { ScrollView; ToolbarContainer }` のような直配置はしない。

理由:
1. `ScrollView` のコンテンツインセットに toolbar 分が自動加算される
2. スクロール中にメッセージが toolbar 下に潜り、Liquid Glass の morph が効く
3. iOS のキーボード回避が自動で効く

## Protocols

```swift
// MARK: - Attachment

public protocol ToolbarAttachment: Sendable, Identifiable where ID == String {
    var id: String { get }
    var displayName: String { get }
    var icon: AttachmentIcon { get }
}

public enum AttachmentIcon: Sendable, Hashable {
    case system(String)
    case fileURL(URL)
    case image(URL)
}

// MARK: - Slash command

public struct SlashCommand: Identifiable, Sendable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let icon: String
}

public protocol SlashCommandProvider: Sendable {
    func commands(matching query: String) async -> [SlashCommand]
}

public struct StaticSlashCommandProvider: SlashCommandProvider { ... }

// MARK: - Voice

public enum VoiceState: Sendable { case idle, recording, transcribing }
public enum VoiceResult: Sendable { case text(String), audio(URL) }

@MainActor
public protocol VoiceInputProvider: AnyObject {
    var state: VoiceState { get }
    func startRecording() async throws
    func stopRecording() async throws -> VoiceResult
    func cancel() async
}

/// Stream of normalized (0...1) audio amplitude samples used by
/// ``VoiceWaveform``. `VoiceInputProvider` and `VoiceAmplitudeSource` are
/// intentionally separate protocols — recording lifecycle vs. visualization
/// data — but a single concrete type may conform to both.
public protocol VoiceAmplitudeSource: AnyObject, Sendable {
    func amplitudeStream() -> AsyncStream<Float>
}

extension View {
    /// Subscribes to `source` and pumps each sample into `amplitudes`,
    /// keeping the array bounded to `capacity` (newest-last sliding window).
    /// Subscription lifetime follows `.task(id:)` semantics keyed off the
    /// source's object identity. Passing `nil` clears the buffer.
    public func voiceAmplitudes(
        from source: (any VoiceAmplitudeSource)?,
        into amplitudes: Binding<[Float]>,
        capacity: Int = 200
    ) -> some View
}

// MARK: - Inline attachment marker (e.g. [[path:/Users/foo]])

public protocol InlineAttachmentRenderer: Sendable {
    var markerPrefix: String { get }
    var markerSuffix: String { get }
    func marker(for url: URL) -> String?
    #if os(macOS)
    @MainActor func makeAttachment(payload: String, font: NSFont) -> NSTextAttachment?
    #else
    @MainActor func makeAttachment(payload: String, font: UIFont) -> NSTextAttachment?
    #endif
}
```

## Built-in attachments

3 種類すべて `URL` を内包する軽量実装。`NSImage` / `UIImage` を持たず、表示は SwiftUI の `Image(nsImage:)` / `Image(uiImage:)` を chip 内で必要時に解決する。

| Type | URL の意味 | チップ表現 |
|---|---|---|
| `FileAttachment` | 任意ファイル | system icon + filename |
| `PathAttachment` | フォルダ | folder icon + folder name |
| `ImageAttachment` | 画像ファイル | thumbnail + filename |

旧 Bob の `PathAttachment` (`NSTextAttachment` ベース、テキスト中にインライン) も `ToolbarEditor` 内で同等のインライン表示が可能 (`InlineAttachmentRenderer` 経由)。`[[path:/Users/foo]]` 形式の marker で text シリアライズと往復する。

## Editor

### Public surface (`ToolbarEditor`)

```swift
public struct ToolbarEditor: View {
    public init(
        text: Binding<String>,
        contentHeight: Binding<CGFloat>,
        isFocused: Binding<Bool>,
        placeholder: String = "Message...",
        rightInset: CGFloat = 0,
        onCommandReturn: @escaping () -> Void = {},
        onKeyEvent: @escaping (EditorKey) -> Bool = { _ in false },
        onPasteAttachment: @escaping (URL) -> Void = { _ in }
    )
}
```

### macOS 実装

`NSScrollView { NSTextView }` を `NSViewRepresentable`。
- 自動高さ計算 (`layoutManager.usedRect`)
- `Cmd+Return` で `onCommandReturn`
- 矢印 / Tab / Esc は `EditorKey` に変換して `onKeyEvent` へ転送
- `registerForDraggedTypes` でファイル URL drop → `onPasteAttachment`
- `NSTextAttachment` でインライン attachment 表示 (`InlineAttachmentRenderer` 連携)

### iOS / iPadOS 実装

`UITextView` を `UIViewRepresentable`。
- `sizeThatFits` で高さ報告
- `keyCommands` override で `Cmd+Return` / 矢印 / Esc / Tab を `UIKeyCommand` 化
- ペーストボード経由のファイル URL を `onPasteAttachment` に通知
- `NSTextAttachment` でインライン attachment 表示

### KeyEvent abstraction

プラットフォーム共通の enum で `up / down / return / tab / escape` を表現。Carbon 依存を Toolbar 内に閉じ込める。

```swift
public enum EditorKey: Sendable, Equatable {
    case up
    case down
    case `return`
    case tab
    case escape
    case other
}
```

## Liquid Glass guidelines

- 親 View は `ToolbarContainer` を使う — 内部で `GlassEffectContainer` (morph domain) と統一 slab (`.glassEffect(.regular, in: .rect(cornerRadius: 28))`) の二段構成を持つ
- **`ToolbarEditor` には呼び出し側で `.glassEffect(...)` を付けない** — slab と二重ガラスになるため。プレーンに slab 上に乗せる
- 円形ボタン (Send / Stop / Voice / Menu): `GlassCircleButtonStyle` または内部で `.glassEffect(.regular, in: .circle)`。slab と morph 連結する
- 添付チップ: `.glassEffect(.regular, in: .capsule)` (`AttachmentChip` 内蔵)
- Slash popup: `.glassEffect(.regular, in: .rect(cornerRadius: 12))` (`SlashCommandPopup` 内蔵)。`ToolbarContainer` の **内側** に置くと slab と同じ morph domain で連結する
- カラーアクセント: `.glassEffect(.regular.tint(.accentColor.opacity(0.3)), ...)`
- hover / focus 状態で `.regular` <-> `.clear` を切り替えてユーザー操作のフィードバック

## Bob 連携 (別タスク)

Toolbar 完成後、Bob 側で以下を実施する。本ドキュメントの範囲外。

- `BobKit/Sources/BobUI/Chat/MessageInputView.swift` 削除
- `BobKit/Sources/BobUI/Chat/TextView.swift` 削除
- `BobKit/Sources/BobUI/Chat/SlashCommand*.swift` 削除
- `BobKit/Sources/BobUI/Chat/PathAttachment.swift` 削除
- `BobKit` に Toolbar を依存追加
- `FloatingChatView` 内で `ToolbarContainer` を組み立て、`ConnectedAppView` を action 行 (`HStack`) 内の任意位置に挿入
- Bob の `SkillManager` を `SlashCommandProvider` に適合させ、`SlashCommandPopup` の commands を直接バインド
- `[[path:/...]]` marker は `PathInlineRenderer` (built-in 予定) 経由で `ToolbarEditor` に流す

## Open questions

実装中に判断が必要になりそうな項目:

- インライン attachment の marker 形式: `[[path:...]]` 互換にするか、汎用 `[[<type>:<id>]]` にするか
- Slash popup の最大行数 / 高さ: 既存 Bob 実装は 210pt
- 添付追加時のアニメーションカーブ: spring(0.35, bounce: 0.1) で統一
- iPadOS Stage Manager で複数 Toolbar が同居した場合の voice provider 競合
- 音声録音中の他操作 (送信ボタン押下など) の挙動: cancel? hold?
