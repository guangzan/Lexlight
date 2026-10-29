public struct LexlightColor: Hashable, Sendable, Codable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    public let alpha: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

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

    public var hexRGBA: String {
        String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
    }
}
