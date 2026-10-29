import XCTest
@testable import Lexlight

final class ResourceTests: XCTestCase {
    func testRequiredResourcesArePackaged() throws {
        XCTAssertTrue(FileManager.default.fileExists(atPath: try LexlightResources.javascriptURL().path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: try LexlightResources.stylesheetURL().path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: try LexlightResources.themesURL().path))
    }
}
