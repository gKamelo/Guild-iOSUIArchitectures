//
//  TasksViewModel.swift
//  MVVM
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import Foundation

protocol TasksViewModelDelegate: class {

    func viewModelDidChange(to viewState: TasksViewModel.ViewState)
    func viewModelDidRemoveItem(at index: Int)
}

final class TasksViewModel {

    enum TaskState {

        case normal, endingSoon, overdue
    }

    enum ViewState {

        case `init`, empty, loading, ready
    }

    private let networkService = NetworkService(baseURL: SharedConstant.networkURL)

    private var tasks = [Task]()
    private var viewState = ViewState.init {
        didSet {
            self.delegate?.viewModelDidChange(to: self.viewState)
        }
    }

    weak var delegate: TasksViewModelDelegate? {
        didSet {
            self.delegate?.viewModelDidChange(to: self.viewState)
        }
    }

    var numberOfItems: Int {
        return self.tasks.count
    }

    // MARK: Tasks manipulation
    func load() {
        let allTask = AllTaskNetworkTask()

        self.viewState = .loading

        self.networkService.fetch(for: allTask) { [weak self] tasks in
            guard let `self` = self else { return }

            self.tasks = tasks.sorted(by: { first, second -> Bool in
                if let firstDate = first.dueDate,
                    let secondDate = second.dueDate {
                    return firstDate < secondDate
                } else if first.dueDate != nil || second.dueDate != nil {
                    return true
                } else {
                    return false
                }
            })

            if self.tasks.isEmpty {
                self.viewState = .empty
            } else {
                self.viewState = .ready
            }
        }
    }

    func add(_ task: Task) {
        if let taskDate = task.dueDate, let taskIndex = self.tasks.index(where: { task -> Bool in
            if let dueDate = task.dueDate {
                return dueDate > taskDate
            } else {
                return true
            }
        }) {
            self.tasks.insert(task, at: taskIndex)
        } else {
            self.tasks.append(task)
        }

        self.viewState = .ready
    }

    func delete(at index: Int) {
        let removeTask = RemoveTaskNetworkTask(identifier: self.tasks[index].id)
        self.networkService.fetch(for: removeTask, success: { _ in
            print(#function + " - \(index)")
        })

        self.tasks.remove(at: index)
        self.delegate?.viewModelDidRemoveItem(at: index)

        if self.tasks.isEmpty {
            self.viewState = .empty
        }
    }

    // MARk: - Tasks info
    func task(at index: Int) -> Task {
        return self.tasks[index]
    }

    func taskState(at index: Int) -> TaskState {
        let task = self.task(at: index)
        let state: TaskState

        if let taskDate = task.dueDate {
            let timeLeft = taskDate.timeIntervalSince1970 - Date().timeIntervalSince1970

            if timeLeft < 0 {
                state = .overdue
            } else if timeLeft < 72 * 3600 {
                state = .endingSoon
            } else {
                state = .normal
            }
        } else {
            state = .normal
        }

        return state
    }
}
