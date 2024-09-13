//
//  CreateProject.swift
//  
//
//  Created by Brian Hasenstab on 9/13/24.
//

import Foundation
import Fluent

struct CreateProject: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(Project.schema)
      .field(Project.Keys.id, .string, .identifier(auto: false), .required)
      .field(Project.Keys.name, .string, .required)
      .field(Project.Keys.subdomain, .string, .required)
      .field(Project.Keys.createdAt, .datetime, .required)
      .field(Project.Keys.updatedAt, .datetime, .required)
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema(Project.schema).delete()
  }
}
