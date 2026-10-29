import Foundation

#if canImport(AppKit)
    import AppKit
    /// The platform font type used by the AppKit renderer.
    public typealias LexlightFont = NSFont
    /// The platform colour type used by the AppKit renderer.
    public typealias LexlightPlatformColor = NSColor
#elseif canImport(UIKit)
    import UIKit
    /// The platform font type used by the UIKit renderer.
    public typealias LexlightFont = UIFont
    /// The platform colour type used by the UIKit renderer.
    public typealias LexlightPlatformColor = UIColor
#endif

extension LexlightColor {
    /// Converts this portable colour to AppKit `NSColor` or UIKit `UIColor`.
    public var platformColor: LexlightPlatformColor {
        LexlightPlatformColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }
}

enum PlatformFont {
    static func applying(_ style: HighlightFontStyle, to font: LexlightFont) -> LexlightFont {
        var result = font
        #if canImport(AppKit)
            if style.contains(.bold) {
                result = NSFontManager.shared.convert(result, toHaveTrait: .boldFontMask)
            }
            if style.contains(.italic) {
                result = NSFontManager.shared.convert(result, toHaveTrait: .italicFontMask)
            }
        #elseif canImport(UIKit)
            var traits = result.fontDescriptor.symbolicTraits
            if style.contains(.bold) {
                traits.insert(.traitBold)
            }
            if style.contains(.italic) {
                traits.insert(.traitItalic)
            }
            if let descriptor = result.fontDescriptor.withSymbolicTraits(traits) {
                result = UIFont(descriptor: descriptor, size: result.pointSize)
            }
        #endif
        return result
    }
}
