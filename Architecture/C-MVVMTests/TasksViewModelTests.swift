//
//  TasksViewModelTests.swift
//  C-MVVMTests
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import XCTest
@testable import C_MVVM

class TasksViewModelTests: XCTestCase {

    // swiftlint:disable:next weak_delegate
    private var spyDelegate: TasksViewModelDelegateSpy!
    private var sut: TasksViewModel!

    override func setUp() {
        super.setUp()

        self.spyDelegate = TasksViewModelDelegateSpy()
        self.sut = TasksViewModel(networkService: NetworkService(baseURL: URL(string: "mock://blabla")!))
        self.sut.delegate = self.spyDelegate

        URLProtocol.registerClass(GetTasksMockURLResponseProtocol.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(GetTasksMockURLResponseProtocol.self)

        super.tearDown()
    }

    // MARK: - Setup
    func test_fresh_willNotHaveTasks() {
        XCTAssertEqual(self.sut.numberOfItems, 0)
    }

    func test_addDelegate_willTriggerViewStateChange() {
        let localSpyDelegate = TasksViewModelDelegateSpy()

        self.sut.delegate = localSpyDelegate

        XCTAssertEqual(localSpyDelegate.viewStateCalled, 1)
    }

    // MARK: - Load
    func test_loadSuccess_willAddTasks() {
        let loadExpectation = self.expectation(description: "wait for my data")

        self.sut.load()

        self.spyDelegate.didChange = { [unowned self] viewState in
            if viewState == .ready {
                XCTAssertEqual(self.spyDelegate.viewStateCalled, 3)
                XCTAssertEqual(self.sut.numberOfItems, 2)

                loadExpectation.fulfill()
            }
        }

        self.wait(for: [loadExpectation], timeout: 3.0)
    }

    // MARK: - Add
    func test_add_willExtendTasks() {
        let task = Task(id: 1, name: "test", description: nil, dueDate: nil)

        self.sut.add(task)

        XCTAssertEqual(self.sut.numberOfItems, 1)
    }

    // MARK: - Delete
    func test_delete_willRemoveTask() {
        let deleteExpecatation = self.expectation(description: "i miss my data")
        let task = Task(id: 1, name: "test", description: nil, dueDate: nil)

        self.sut.add(task)

        self.spyDelegate.didRemove = { [unowned self] index in
            XCTAssertEqual(index, 0)
            XCTAssertEqual(self.sut.numberOfItems, 0)
            XCTAssertEqual(self.spyDelegate.itemRemoveCalled, 1)

            deleteExpecatation.fulfill()
        }
        self.sut.delete(at: 0)

        self.wait(for: [deleteExpecatation], timeout: 3.0)
    }
}

// MARK: - Helpers
fileprivate class GetTasksMockURLResponseProtocol: MockURLResponseProtocol {

    override var mockData: Data? {
        return self.loadData(from: "tasks_response")
    }
}

fileprivate class DeleteTaskMockURLResponseProtocol: MockURLResponseProtocol {

    override var mockData: Data? {
        return self.loadData(from: "task_delete_response")
    }
}

fileprivate class TasksViewModelDelegateSpy: TasksViewModelDelegate {

    private(set) var viewStateCalled = 0
    private(set) var itemRemoveCalled = 0

    var didChange: ((TasksViewModel.ViewState) -> Void)?
    var didRemove: ((Int) -> Void)?

    func viewModelDidChange(to viewState: TasksViewModel.ViewState) {
        self.viewStateCalled += 1

        self.didChange?(viewState)
    }

    func viewModelDidRemoveItem(at index: Int) {
        self.itemRemoveCalled += 1

        self.didRemove?(index)
    }
}
