import XCTest

@testable import Lexlight

final class ResourceTests: XCTestCase {
    func testRequiredResourcesArePackaged() throws {
        XCTAssertTrue(FileManager.default.fileExists(atPath: try LexlightResources.javascriptURL().path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: try LexlightResources.stylesheetURL().path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: try LexlightResources.themesURL().path))
        XCTAssertNotNil(
            LexlightResources.bundle.url(forResource: "Lexlight-LICENSE", withExtension: "md")
        )
        XCTAssertNotNil(
            LexlightResources.bundle.url(forResource: "Lexlight-NOTICE", withExtension: "md")
        )
        XCTAssertNotNil(
            LexlightResources.bundle.url(forResource: "LICENSE", withExtension: "md")
        )
        XCTAssertNotNil(
            LexlightResources.bundle.url(forResource: "NOTICE", withExtension: "md")
        )
    }
}
