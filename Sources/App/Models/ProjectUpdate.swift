//
//  ProjectUpdate.swift
//  
//
//  Created by Brian Hasenstab on 9/13/24.
//

import Foundation
import Vapor
import Fluent

final class ProjectUpdate: Model, @unchecked Sendable {
  static var schema: String = "project_updates"
  
  struct Keys {
    static var id: FieldKey { "id" }
    static var title: FieldKey { "title" }
    static var content: FieldKey { "content" }
    static var projectId: FieldKey { "project_id" }

    static var createdAt: FieldKey { "created_at" }
    static var updatedAt: FieldKey { "updated_at" }
  }
  
  @ID(custom: Keys.id, generatedBy: .user) var id: String?
  @Field(key: Keys.title) var title: String
  @Field(key: Keys.content) var content: String
  
  @Timestamp(key: Keys.createdAt, on: .create) var createdAt: Date?
  @Timestamp(key: Keys.updatedAt, on: .update) var updatedAt: Date?
  
  @Parent(key: Keys.projectId) var project: Project
  
  init() {}
  
  init(title: String, content: String, projectId: String) {
    self.id = generateRandomCode(prefix: "update")
    self.title = title
    self.content = content
    self.$project.id = projectId
  }
}
