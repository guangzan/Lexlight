# Lexlight

[English](README.md) | **简体中文**

[![CI](https://github.com/guangzan/Lexlight/actions/workflows/ci.yml/badge.svg)](https://github.com/guangzan/Lexlight/actions/workflows/ci.yml)
[![Swift 6](https://img.shields.io/badge/Swift-6-F05138.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-macOS%2014%2B%20%7C%20iOS%2017%2B-blue.svg)](#环境要求)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

Lexlight 是面向 Apple 平台的生产级语法高亮库。它封装固定版本的
`@pierre/highlights`，让 SwiftUI / AppKit / UIKit 原生产物与宿主自己的
`WKWebView` 预览共享同一套 token、语言别名和主题目录。

它替代 Highlightr 在 Apple 应用中常见的角色，但不需要为 Web 内容再维护一套
语法引擎，也不会让原生预览和导出的 HTML 产生高亮差异。

## 为什么选择 Lexlight

- **一套 tokenizer，两个渲染面。** 原生富文本和 Web 代码块得到同一组 token
  与颜色。
- **完全离线。** JavaScript、Wasm、全部语言和 75 个类型化主题随包分发，
  运行时无需下载。
- **Swift 6 异步 API。** 单 actor 串行执行，支持协作式取消，结果满足
  `Sendable`，渲染留在 UI 边界。
- **自动运行时降级。** WebAssembly 可用时优先 JavaScriptCore；不可用时由内部
  `WKWebView` 执行同一份 tokenizer。
- **WebView 归宿主所有。** Lexlight 只提供稳定的 JavaScript / CSS 资源和窄
  `globalThis.Lexlight` 命名空间，不接管浏览器生命周期。
- **类型化主题。** 内置主题是带 scope 继承的 Swift 值，公开 API 不暴露上游
  原始 JavaScript 对象。
- **资源可复现。** 生成脚本、manifest 哈希、上游许可证与 NOTICE 全部入库并在
  CI 校验。

## 环境要求

- macOS 14 或更高
- iOS 17 或更高
- Swift 6 language mode
- Xcode 16 或更高

不支持 watchOS、tvOS、visionOS、Mac Catalyst，也不提供自动语言检测。

## 安装

在 Xcode 中选择 **File > Add Package Dependencies**，输入：

```text
https://github.com/guangzan/Lexlight.git
```

选择 `Lexlight` library product。

或者在 `Package.swift` 中声明：

```swift
dependencies: [
    .package(url: "https://github.com/guangzan/Lexlight.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["Lexlight"]
    )
]
```

包只公开一个 library product：`Lexlight`。

## 快速开始

```swift
import Lexlight

let highlighter = try await ActorHighlighter(themeID: "github-light")
let result = try await highlighter.tokenize(
    """
    struct Greeting {
        let name: String
    }
    """,
    language: .swift
)

let engine = await highlighter.activeEngine()
print("Lexlight runtime: \(engine.displayName)")
```

建议每个编辑器或文档界面持有一个 `ActorHighlighter`。它通过单个 JavaScript
运行时串行处理请求，tokenizer 启动成本只支付一次。

## 原生渲染

### SwiftUI

```swift
import Lexlight
import SwiftUI

struct HighlightedCode: View {
    let result: HighlightResult

    var body: some View {
        Text(
            result.attributedString(
                baseFont: .system(.body, design: .monospaced)
            )
        )
        .textSelection(.enabled)
    }
}
```

### AppKit 与 UIKit

```swift
let attributed = result.nsAttributedString(
    baseFont: LexlightFont.monospacedSystemFont(ofSize: 13, weight: .regular)
)
```

AppKit 中赋给 `NSTextStorage`，UIKit 中赋给 `UITextView.attributedText`。
Token 偏移使用 UTF-16 code unit，与 `NSRange` 完全一致，emoji 和组合字符不会
错位。

## WebView 集成

Lexlight 不创建也不持有 `WKWebView`，只提供与原生 tokenizer 完全一致的
JavaScript 和 CSS 资源：

```swift
let scriptURL = try LexlightResources.webViewScriptURL()
let stylesheetURL = try LexlightResources.webViewStylesheetURL()
```

需要直接注入字符串时：

```swift
let script = try LexlightResources.javascript()
let stylesheet = try LexlightResources.stylesheet()
```

代码块使用语言 class：

```html
<pre><code class="language-swift">let answer = 42</code></pre>
```

资源加载后调用：

```javascript
Lexlight.highlightAll(document, { theme: "github-light" });
```

公开的 JavaScript 命名空间刻意保持很小：

- `tokenize(code, language, themeID)`
- `highlightElement(element, options)`
- `highlightAll(root, options)`
- `supportedLanguages()`
- `normalizeLanguage(language)`
- `setTheme(themeID)`
- `version`

`[data-no-highlight]` 内的代码块，以及 Mermaid、PlantUML、Markmap 等图表语言
不会被改写。

## 运行时选择

Lexlight 默认先尝试 JavaScriptCore。引擎会先确认当前运行时能够构造
WebAssembly module，再接受 tokenizer。若 JavaScriptCore 无法执行 bundle，
Lexlight 会初始化内部 `WKWebView` 引擎，通过纯 JSON bridge 运行同一份
JavaScript。

```swift
switch await highlighter.activeEngine() {
case .javaScriptCore:
    print("Using JavaScriptCore")
case .webKit:
    print("Using WebKit fallback")
}
```

降级全自动完成，调用方不需要按平台分支。

## 主题与语言

```swift
let registry = try ThemeRegistry.bundled()
let theme = registry.theme(identifier: "one-dark-pro")

let result = try await highlighter.tokenize(
    source,
    language: HighlightLanguage(identifier: "js"),
    theme: theme
)
```

`js`、`ts`、`c++`、`objc`、`language-javascript` 等常见别名会在 tokenization
前归一化。空语言或未知语言解析为 `plain`。

自定义主题只使用可移植值：

```swift
let brand = HighlightTheme(
    id: "brand",
    name: "Brand",
    appearance: .dark,
    editorForeground: LexlightColor(hex: "#F4F1E8"),
    editorBackground: LexlightColor(hex: "#1D211F"),
    syntax: [
        .keyword: HighlightStyle(
            foreground: LexlightColor(hex: "#7FD1C7"),
            fontStyle: .bold
        )
    ]
)
```

## 取消

所有异步入口都支持 Swift task cancellation：

```swift
@State private var highlightTask: Task<Void, Never>?

func refresh() {
    highlightTask?.cancel()
    highlightTask = Task {
        guard let result = try? await highlighter.tokenize(source, language: language)
        else { return }
        guard !Task.isCancelled else { return }
        self.result = result
    }
}
```

Lexlight 在进入引擎前和返回结果前都会检查取消状态，过期请求不会覆盖当前 UI。

## 错误

公开错误统一使用 `LexlightError`：

```swift
do {
    let result = try await highlighter.tokenize(source, language: .swift)
    render(result)
} catch let error as LexlightError {
    diagnostics.record(error)
} catch {
    diagnostics.record(error)
}
```

错误类别覆盖资源缺失、引擎初始化、运行时不支持、JavaScript 执行、解码、
序列化、非法主题和取消。

## 示例应用

`Examples/LexlightDemo` 是 macOS 与 iOS 共用的 SwiftUI 可执行示例，演示：

- 可编辑源码；
- `AttributedString` 与 `NSAttributedString`；
- 使用 Lexlight 资源的 `WKWebView`；
- 语言与主题同步切换；
- 当前引擎诊断；
- 未知语言回退到 `plain`。

```sh
xcodebuild -scheme LexlightDemo -destination 'platform=macOS' build
```

```sh
xcodebuild -scheme LexlightDemo \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

该示例只用于展示集成方式，不是第二个公开产品。

## 重新生成资源

`Sources/Lexlight/Resources` 下的生成文件已入库，包使用者不需要 Node.js 或
Wasm 工具链。

贡献者修改 tokenizer 或主题时执行：

```sh
pnpm install --frozen-lockfile
pnpm run build:highlights
pnpm run verify:highlights
```

不要手动编辑 `lexlight-highlights.js`、`themes.json` 或
`resource-manifest.json`。CI 会重新生成资源并在发生 drift 时失败。

## 开发

```sh
swift build
swift test
swift-format lint --strict --recursive Sources Tests Examples Package.swift
swiftlint lint --strict
```

DocC 文档位于 `Sources/Lexlight/Lexlight.docc`。

## 许可证

Lexlight 使用 Apache License 2.0。见 [LICENSE](LICENSE) 与
[NOTICE.md](NOTICE.md)。

随包分发的 `@pierre/highlights` 0.2.0 同样使用 Apache-2.0，其上游许可证和
NOTICE 位于 `Sources/Lexlight/Resources/Vendor/PierreHighlights/`。
