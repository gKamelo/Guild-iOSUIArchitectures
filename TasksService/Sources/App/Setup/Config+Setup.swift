import FluentProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try self.setupProviders()
        try self.setupPreparations()
        self.setupMiddlewares()
    }

    /// Configure providers
    private func setupProviders() throws {
        try self.addProvider(FluentProvider.Provider.self)
    }

    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        self.preparations.append(Task.self)
    }

    private func setupMiddlewares() {
        self.addConfigurable(middleware: VersionMiddleware(), name: "version")
        self.addConfigurable(middleware: ResponseMiddleware(), name: "response")
        self.addConfigurable(middleware: DelayMiddleware(), name: "delay")
    }
}
