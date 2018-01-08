//
//  Task.swift
//  App
//

import Vapor
import FluentProvider
import HTTP

final class Task: Model, ResponseRepresentable {

    fileprivate struct Key {

        static let id = "id"
        static let name = "name"
        static let description = "description"
        static let dueDate = "dueDate"
    }

    let storage = Storage()

    let name: String
    let description: String?
    let dueDate: Date?

    init(name: String, description: String?, dueDate: Date?) {
        self.name = name
        self.description = description
        self.dueDate = dueDate
    }

    init(row: Row) throws {
        self.name = try row.get(Key.name)
        self.description = try row.get(Key.description)
        self.dueDate = try row.get(Key.dueDate)
    }

    func makeRow() throws -> Row {
        var row = Row()

        try row.set(Key.name, self.name)
        if let description = self.description { try row.set(Key.description, description) }
        if let dueDate = self.dueDate { try row.set(Key.dueDate, dueDate) }

        return row
    }
}

// MARK: - Fluent preparation
extension Task: Preparation {
    /// Prepares a table/collection in the database
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Key.name)
            builder.string(Key.description, optional: true)
            builder.date(Key.dueDate, optional: true)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSON
extension Task: JSONConvertible {

    convenience init(json: JSON) throws {
        self.init(name: try json.get(Key.name),
                  description: try json.get(Key.description),
                  dueDate: try json.get(Key.dueDate))
    }

    func makeJSON() throws -> JSON {
        var json = JSON()

        try json.set(Key.id, self.id)
        try json.set(Key.name, self.name)
        if let description = self.description { try json.set(Key.description, description) }
        if let dueDate = self.dueDate { try json.set(Key.dueDate, dueDate) }

        return json
    }
}
