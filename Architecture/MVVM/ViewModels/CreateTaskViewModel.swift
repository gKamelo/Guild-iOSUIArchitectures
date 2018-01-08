//
//  CreateTaskViewModel.swift
//  MVVM
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import Foundation

protocol CreateTaskViewModelDelegate: class {

    func viewModelDidChange(to viewState: CreateTaskViewModel.ViewState)
    func viewModelDidChange(to field: CreateTaskViewModel.Field)
}

final class CreateTaskViewModel {

    enum ViewState {

        case `init`, creating, created(Task)
    }

    enum Field {

        case title, description, date
    }

    private let networkServie = NetworkService(baseURL: SharedConstant.networkURL)

    private var dueDate: Date?
    private(set) var title: String?
    private(set) var description: String?

    private var viewState = ViewState.init {
        didSet {
            self.delegate?.viewModelDidChange(to: self.viewState)
        }
    }

    weak var delegate: CreateTaskViewModelDelegate? {
        didSet {
            self.delegate?.viewModelDidChange(to: self.viewState)
        }
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "dd/MM/yyyy"

        return formatter
    }()

    var dueDateName: String {
        if let dueDate = self.dueDate {
            return self.dateFormatter.string(from: dueDate)
        } else {
            return "Set due date"
        }
    }

    var canCreate: Bool {
        return !(self.title?.isEmpty ?? true)
    }

    func updateTitle(with title: String?) {
        self.title = title

        self.delegate?.viewModelDidChange(to: .title)
    }

    func updateDescription(with description: String) {
        self.description = description.isEmpty ? nil : description

        self.delegate?.viewModelDidChange(to: .description)
    }

    func updateDate(with dueDate: Date?) {
        self.dueDate = dueDate

        self.delegate?.viewModelDidChange(to: .date)
    }

    func create() {
        guard let title = self.title else { return }

        let createTask = CreateTaskNetworkTask(name: title, description: self.description, dueDate: self.dueDate)

        self.viewState = .creating

        self.networkServie.fetch(for: createTask) { [weak self] task in
            guard let `self` = self else { return }

            self.updateTitle(with: "")
            self.updateDescription(with: "")
            self.updateDate(with: nil)

            self.viewState = .created(task)
        }
    }
}
