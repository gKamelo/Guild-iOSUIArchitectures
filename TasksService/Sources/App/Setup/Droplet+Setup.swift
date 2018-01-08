@_exported import Vapor

extension Droplet {
    public func setup() throws {
        try self.setupRoutes()
    }
}
