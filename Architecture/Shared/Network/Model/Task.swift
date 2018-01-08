//
//  Task.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import Foundation

struct Task {

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        return formatter
    }()

    let id: Int
    let name: String
    let description: String?
    let dueDate: Date?
}

extension Task {

    init?(json: JSON) {
        guard let id = json["id"] as? Int,
            let name = json["name"] as? String else { return nil }

        self.id = id
        self.name = name
        self.description = json["description"] as? String

        if let dueDateRaw = json["dueDate"] as? String,
            let dueDate = Task.dateFormatter.date(from: dueDateRaw) {
            self.dueDate = dueDate
        } else {
            self.dueDate = nil
        }
    }
}
