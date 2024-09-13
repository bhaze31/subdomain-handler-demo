//
//  PublicPagesController.swift
//  
//
//  Created by Brian Hasenstab on 9/13/24.
//

import Foundation
import Vapor
import Fluent

final class PublicPagesController: RouteCollection {
  @Sendable func projectPage(request: Request) async throws -> View {
    guard let project = request.storage.get(ProjectKey.self) else {
      return try await request.view.render("Public/404")
    }
    
    let updates = try await ProjectUpdate.query(on: request.db).filter(\.$project.$id == project.id!).sort(\.$createdAt, .descending).all()

    return try await request.view.render("Public/project", ProjectContent(project: project, updates: updates))
  }

  func boot(routes: RoutesBuilder) throws {
    let withProject = routes.grouped([LoadProjectMiddleware()])
    
    withProject.get(use: projectPage)
  }
}
