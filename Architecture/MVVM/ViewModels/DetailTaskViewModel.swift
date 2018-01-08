//
//  DetailTaskViewModel.swift
//  MVVM
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import Foundation

struct DetailTaskViewModel {

    private let task: Task

    var title: String {
        return self.task.name
    }

    var description: String? {
        return self.task.description
    }

    var dueDate: String? {
        return self.task.dueDate?.description
    }

    init(task: Task) {
        self.task = task
    }
}
