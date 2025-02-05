import NIOSSL
import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor
import SubdomainHandler

// configures your application
public func configure(_ app: Application) async throws {
  app.http.server.configuration.port = 3500
  // uncomment to serve files from /Public folder
   app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  
  app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
  
  app.migrations.add(CreateProject())
  app.migrations.add(CreateProjectUpdate())
  
  app.views.use(.leaf)
  
  try await app.autoMigrate()

  // register routes
  try routes(app)
  
  app.enableSubdomains()
}
