//
//  LoadProjectMiddleware.swift
//  
//
//  Created by Brian Hasenstab on 9/13/24.
//

import Foundation
import Vapor
import Fluent

final class LoadProjectMiddleware: AsyncMiddleware {
  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    if let host = request.headers["host"].first {
      if let subdomain = host.split(separator: ".").first {
        if let project = try? await Project.query(on: request.db).filter(\.$subdomain == String(subdomain)).first() {
          await request.storage.setWithAsyncShutdown(ProjectKey.self, to: project)
        }
      }
    }
    return try await next.respond(to: request)
  }
}
