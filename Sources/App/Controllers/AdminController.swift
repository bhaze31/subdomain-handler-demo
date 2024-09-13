//
//  AdminController.swift
//  
//
//  Created by Brian Hasenstab on 9/13/24.
//

import Foundation
import Vapor

final class AdminController: RouteCollection {
  @Sendable func adminPanel(request: Request) async throws -> Response {
    let projects = try await Project.query(on: request.db).all()

    return try await request.view.render("Admin/index", ["projects": projects]).encodeResponse(for: request)
  }
  
  @Sendable func createProjectForm(request: Request) async throws -> Response {
    return try await request.view.render("Admin/create").encodeResponse(for: request)
  }
  
  @Sendable func createProject(request: Request) async throws -> Response {
    struct ProjectForm: Content {
      var name: String
      var subdomain: String
    }

    guard let content = try? request.content.decode(ProjectForm.self) else {
      return request.redirect(to: "/create")
    }
    
    let project = Project(name: content.name, subdomain: content.subdomain)
    
    try await project.save(on: request.db)
    
    return request.redirect(to: "/", redirectType: .normal)
  }

  func boot(routes: RoutesBuilder) throws {
    routes.get(use: adminPanel)
    routes.get("create", use: createProjectForm)
    routes.post("create", use: createProject)
  }
}
