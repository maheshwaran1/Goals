//
//  RealmDatabase.swift
//  Goals
//
//  Created by MAHESHWARAN on 22/03/22.
//

import UIKit
import RealmSwift

class RealmDatabase {
  //singleton
  static let shared = RealmDatabase()
  
  private var realm = try! Realm()
  //File location
  func getDatabaseLocationURL()->URL? {
    return Realm.Configuration.defaultConfiguration.fileURL
  }
  
  //MARK: save
  func saveContentToRealm(newGoals: Goals) {
    try! realm.write({
      realm.add(newGoals)
    })
  }
  
  //MARK: Retrive Data from Realm
  func getAllContent()-> [Goals] {
    return Array(realm.objects(Goals.self))
  }
  //MARK: - Delete Data
  func deleteAllContent(){
    try! realm.write({
      realm.deleteAll()
    })
  }
  
  //MARK: delete
  func deleteContentToRealm(newGoals: Goals) {
    try! realm.write({
      realm.delete(newGoals)
    })
  }
  
  //MARK: Edit
  func updateContentToRealm(oldGoals: Goals, newGoals: Goals) {
    try! realm.write({
      oldGoals.title =  newGoals.title
      oldGoals.tags = newGoals.tags
    })
  }
}

class Goals: Object {
  @Persisted var category: String
  @Persisted var title: String
  @Persisted var tags: String
  
  convenience init(category: String, title: String, tags: String) {
    self.init()
    self.category = category
    self.title = title
    self.tags = tags
  }
}

