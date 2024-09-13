//
//  Helpers.swift
//  
//
//  Created by Brian Hasenstab on 9/13/24.
//

import Foundation

func generateRandomCode(prefix: String) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
  return "\(prefix)_\(String((0..<12).map{ _ in letters.randomElement()! }))"
}
