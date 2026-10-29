import Foundation

public enum LexlightResources {
    public static var bundle: Bundle {
        .module
    }

    public static func javascriptURL() throws -> URL {
        try resource(named: "lexlight-highlights", extension: "js")
    }

    public static func stylesheetURL() throws -> URL {
        try resource(named: "lexlight", extension: "css")
    }

    public static func themesURL() throws -> URL {
        try resource(named: "themes", extension: "json")
    }

    public static func javascript() throws -> String {
        do {
            return try String(contentsOf: javascriptURL(), encoding: .utf8)
        } catch let error as LexlightError {
            throw error
        } catch {
            throw LexlightError.resourceMissing("lexlight-highlights.js")
        }
    }

    private static func resource(named name: String, extension ext: String) throws -> URL {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw LexlightError.resourceMissing("\(name).\(ext)")
        }
        return url
    }
}
