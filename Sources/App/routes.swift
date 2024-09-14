import Fluent
import Vapor
import SubdomainHandler

func routes(_ app: Application) throws {
  try app.register(collection: AdminController(), at: "admin")
  
  try app.register(collection: AppController(), at: "app")
  
  try app.register(collection: PublicPagesController(), at: "*")
  
  app.get { request -> String in
    return "Hello to the subdomain tutorial people!"
  }
}
