//
//  CreateTaskNetworkTask.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import Foundation

struct CreateTaskNetworkTask: NetworkTask {

    let name: String
    let description: String?
    let dueDate: Date?

    let endPoint = "tasks"
    let method = HTTPMethod.post

    var body: Data? {

        let content: [String: Any?] = ["name": self.name,
                                      "description": self.description,
                                      "dueDate": self.dueDate?.timeIntervalSince1970]

        return try? JSONSerialization.data(withJSONObject: content, options: [])
    }

    func parse(_ data: Any) -> Task? {
        guard let json = data as? JSON else { return nil }

        return Task(json: json)
    }
}
