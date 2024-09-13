//
//  Project.swift
//  
//
//  Created by Brian Hasenstab on 9/13/24.
//

import Foundation
import Fluent
import Vapor

final class Project: Model, Content, @unchecked Sendable {
  static var schema: String = "projects"
  
  struct Keys {
    static var id: FieldKey { "id" }
    static var name: FieldKey { "project_name" }
    static var subdomain: FieldKey { "subdomain" }
    static var createdAt: FieldKey { "created_at" }
    static var updatedAt: FieldKey { "updated_at" }
  }
  
  @ID(custom: Keys.id, generatedBy: .user) var id: String?
  @Field(key: Keys.name) var projectName: String
  @Field(key: Keys.subdomain) var subdomain: String
  
  @Timestamp(key: Keys.createdAt, on: .create) var createdAt: Date?
  @Timestamp(key: Keys.updatedAt, on: .update) var updatedAt: Date?
  
  @Children(for: \.$project) var updates: [ProjectUpdate]
  
  init() {
    self.id = generateRandomCode(prefix: "project")
  }
  
  init(name: String, subdomain: String) {
    self.id = generateRandomCode(prefix: "project")
    self.projectName = name
    self.subdomain = subdomain
  }
}

struct ProjectKey: StorageKey {
  typealias Value = Project
}

