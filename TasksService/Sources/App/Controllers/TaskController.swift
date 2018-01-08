//
//  TaskController.swift
//  App
//

import Vapor
import HTTP

final class TaskController: ResourceRepresentable, EmptyInitializable {

    func index(_ request: Request) throws -> ResponseRepresentable {
        return try Task.all().makeJSON()
    }

    func store(_ request: Request) throws -> ResponseRepresentable {
        let task = try request.task()

        try task.save()

        return task
    }

    func show(_ request: Request, task: Task) throws -> ResponseRepresentable {
        return task
    }

    func delete(_ req: Request, task: Task) throws -> ResponseRepresentable {
        try task.delete()

        return JSON(true)
    }

    func makeResource() -> Resource<Task> {
        return Resource(index: self.index,
                        store: self.store,
                        show: self.show,
                        destroy: self.delete)
    }
}

fileprivate extension Request {

    func task() throws -> Task {
        guard let json = self.json else { throw Abort.badRequest }

        return try Task(json: json)
    }
}
