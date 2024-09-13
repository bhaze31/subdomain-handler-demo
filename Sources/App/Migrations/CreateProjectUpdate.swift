//
//  CreateProjectUpdate.swift
//  
//
//  Created by Brian Hasenstab on 9/13/24.
//

import Foundation
import Fluent

struct CreateProjectUpdate: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(ProjectUpdate.schema)
      .field(ProjectUpdate.Keys.id, .string, .identifier(auto: false), .required)
      .field(ProjectUpdate.Keys.title, .string, .required)
      .field(ProjectUpdate.Keys.content, .string, .required)
      .field(ProjectUpdate.Keys.projectId, .string, .references(Project.schema, Project.Keys.id))
      .field(ProjectUpdate.Keys.createdAt, .datetime, .required)
      .field(ProjectUpdate.Keys.updatedAt, .datetime, .required)
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema(ProjectUpdate.schema).delete()
  }
}
