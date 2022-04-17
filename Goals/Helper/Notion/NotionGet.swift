//
//  NotionAPIResponse.swift
//  Goals
//
//  Created by MAHESHWARAN on 22/03/22.
//

import Foundation

struct NotionGet: Codable {
  var results : [Results]
}
struct Results : Codable {
  var properties: Properties
}

struct Properties: Codable {
  var Category: category
  var Tags: tags
  var Title: title
}
struct category: Codable {
  var rich_text : [text]
}
struct tags: Codable {
  var select: Select
}
struct Select: Codable{
  var name: String
}

struct title: Codable {
  var title: [text]
}
struct text: Codable {
  var text : content
}
struct content: Codable {
  var content: String
}
