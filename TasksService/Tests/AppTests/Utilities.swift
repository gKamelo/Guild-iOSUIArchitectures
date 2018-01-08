import Foundation
@testable import App
@testable import Vapor
import XCTest
import Testing
import FluentProvider

class TestCase: XCTestCase {
    override func setUp() {
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        Testing.onFail = XCTFail
    }
}
