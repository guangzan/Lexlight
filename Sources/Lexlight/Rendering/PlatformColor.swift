import Foundation

#if canImport(AppKit)
import AppKit
public typealias LexlightFont = NSFont
public typealias LexlightPlatformColor = NSColor
#elseif canImport(UIKit)
import UIKit
public typealias LexlightFont = UIFont
public typealias LexlightPlatformColor = UIColor
#endif

public extension LexlightColor {
    var platformColor: LexlightPlatformColor {
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
