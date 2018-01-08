import XCTest
import Testing
import HTTP

@testable import Vapor
@testable import App

class TaskControllerTests: TestCase {

    func test_storeTask_willCreateTask() {
        let sut = TaskController()
        let json = self.addTask(for: sut).json

        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["id"])
        XCTAssertNotNil(json?["name"])
        XCTAssertNotNil(json?["description"])
    }

    func test_getAllTask_willReturnTasks() {
        let sut = TaskController()
        _  = self.addTask(for: sut)
        _  = self.addTask(for: sut)
        let request = Request.makeTest(method: .get)

        let response = try! sut.index(request).makeResponse()
        let json = response.json

        XCTAssertNotNil(json?.array)
        XCTAssertEqual(json?.array?.count, 2)
    }

    func test_getTask_willReturnTask() {
        let sut = TaskController()
        let addJson = self.addTask(for: sut).json
        let addId: Int = try! addJson!.get("id")
        let getJson = self.getTask(for: sut, and: addId).json

        XCTAssertNotNil(getJson)
        XCTAssertNotNil(getJson?["id"])
        XCTAssertNotNil(getJson?["name"])
        XCTAssertNotNil(getJson?["description"])

        XCTAssertEqual(getJson?["name"]?.string, "Test")
        XCTAssertEqual(getJson?["description"]?.string, "Test me more")
    }

    func test_deleteTask_willReturnNoTask() {
        let sut = TaskController()
        let addJson = self.addTask(for: sut).json
        let addId: Int = try! addJson!.get("id")
        let task = try! Task.find(addId)!
        let request = Request.makeTest(method: .delete)

        _ = try! sut.delete(request, task: task)

        let response = try! Task.find(addId)

        XCTAssertNil(response)
    }
}

// MARK: - Helpers
extension TaskControllerTests {

    private func addTask(for controller: TaskController) -> Response {
        let request = Request.makeTest(method: .post)

        request.json = try! JSON(node: ["name": "Test", "description": "Test me more"])

        return try! controller.store(request).makeResponse()
    }

    private func getTask(for controller: TaskController, and id: Int) -> Response {
        let request = Request.makeTest(method: .get)
        let task = try! Task.find(id)!

        return try! controller.show(request, task: task).makeResponse()
    }
}

// MARK: - Manifest
extension TaskControllerTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("test_storeTask_willCreateTask", TaskControllerTests.test_storeTask_willCreateTask),
        ("test_getAllTask_willReturnTasks", TaskControllerTests.test_getAllTask_willReturnTasks),
        ("test_getTask_willReturnTask", TaskControllerTests.test_getTask_willReturnTask),
        ("test_deleteTask_willReturnNoTask", TaskControllerTests.test_deleteTask_willReturnNoTask)
    ]
}
