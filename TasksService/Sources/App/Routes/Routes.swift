import Vapor

extension Droplet {
    func setupRoutes() throws {
        try self.resource("tasks", TaskController.self)
    }
}
