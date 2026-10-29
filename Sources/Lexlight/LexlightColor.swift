/// A platform-independent RGBA colour with 8 bits per channel.
public struct LexlightColor: Hashable, Sendable, Codable {
    /// Red channel from 0 to 255.
    public let red: UInt8
    /// Green channel from 0 to 255.
    public let green: UInt8
    /// Blue channel from 0 to 255.
    public let blue: UInt8
    /// Alpha channel from 0 to 255.
    public let alpha: UInt8

    /// Creates a colour from channel values.
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// Parses `#RGB`, `#RGBA`, `#RRGGBB`, or `#RRGGBBAA` hexadecimal text.
    public init?(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") {
            value.removeFirst()
        }
        guard [3, 4, 6, 8].contains(value.count),
            let raw = UInt64(value, radix: 16)
        else {
            return nil
        }

        switch value.count {
        case 3:
            red = UInt8((raw >> 8) & 0xF) * 17
            green = UInt8((raw >> 4) & 0xF) * 17
            blue = UInt8(raw & 0xF) * 17
            alpha = 255
        case 4:
            red = UInt8((raw >> 12) & 0xF) * 17
            green = UInt8((raw >> 8) & 0xF) * 17
            blue = UInt8((raw >> 4) & 0xF) * 17
            alpha = UInt8(raw & 0xF) * 17
        case 6:
            red = UInt8((raw >> 16) & 0xFF)
            green = UInt8((raw >> 8) & 0xFF)
            blue = UInt8(raw & 0xFF)
            alpha = 255
        default:
            red = UInt8((raw >> 24) & 0xFF)
            green = UInt8((raw >> 16) & 0xFF)
            blue = UInt8((raw >> 8) & 0xFF)
            alpha = UInt8(raw & 0xFF)
        }
    }

    /// The colour formatted as uppercase `#RRGGBBAA`.
    public var hexRGBA: String {
        String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
    }
}
