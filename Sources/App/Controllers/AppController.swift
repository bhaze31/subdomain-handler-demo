//
//  AppController.swift
//  
//
//  Created by Brian Hasenstab on 9/13/24.
//

import Foundation
import Vapor
import Fluent

struct ProjectContent: Content {
  var project: Project
  var updates: [ProjectUpdate]
}

final class AppController: RouteCollection {

  @Sendable
  func index(request: Request) async throws -> View {
    let projects = try await Project.query(on: request.db).all()
    
    return try await request.view.render("App/index", ["projects": projects])
  }
  
  @Sendable func viewProject(request: Request) async throws -> View {
    guard let projectId = request.parameters.get("project_id") else {
      throw Abort(.internalServerError)
    }
    
    guard let project = try await Project.find(projectId, on: request.db) else {
      throw Abort(.notFound)
    }
    
    let updates = try await ProjectUpdate.query(on: request.db).filter(\.$project.$id == projectId).sort(\.$createdAt, .descending).all()
    
    return try await request.view.render("App/project", ProjectContent(project: project, updates: updates))
  }
  
  @Sendable func createUpdate(request: Request) async throws -> Response {
    struct UpdateContent: Content {
      var title: String
      var content: String
    }

    guard let projectId = request.parameters.get("project_id") else {
      throw Abort(.internalServerError)
    }
    
    guard let _ = try? await Project.find(projectId, on: request.db) else {
      throw Abort(.notFound)
    }
    
    guard let content = try? request.content.decode(UpdateContent.self) else {
      throw Abort(.badRequest)
    }
    
    let update = ProjectUpdate(title: content.title, content: content.content, projectId: projectId)
    
    try await update.save(on: request.db)

    return request.redirect(to: "/projects/\(projectId)", redirectType: .normal)
  }

  func boot(routes: RoutesBuilder) throws {
    routes.get(use: index)
    routes.get("projects", ":project_id", use: viewProject)
    routes.post("projects", ":project_id", use: createUpdate)
  }
}
