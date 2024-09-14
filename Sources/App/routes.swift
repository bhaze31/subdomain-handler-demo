import Fluent
import Vapor

func routes(_ app: Application) throws {
  app.get { request -> String in
    return "Hello to the subdomain tutorial people!"
  }
}
