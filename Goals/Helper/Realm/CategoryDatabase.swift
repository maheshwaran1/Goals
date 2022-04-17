//
//  CategoryDatabase.swift
//  Goals
//
//  Created by MAHESHWARAN on 30/03/22.


import UIKit
import RealmSwift

class CategoryDatabase {
  //singleton
  static let shared = CategoryDatabase()
  
  private var realm = try! Realm()
  //File location
  func getDatabaseLocationURL()->URL? {
    return Realm.Configuration.defaultConfiguration.fileURL
  }
  
  //MARK: save
  func saveContentToRealm(newGoals: Category) {
    try! realm.write({
      realm.add(newGoals)
    })
  }
  //MARK: Retrive Data from Realm
  func getAllContent()-> [Category] {
    return Array(realm.objects(Category.self))
  }
  //MARK: delete
  func deleteContentToRealm(newGoals: Category) {
    try! realm.write({
      realm.delete(newGoals)
    })
  }
  //MARK: Edit
  func updateContentToRealm(oldGoals: Category, newGoals: Category) {
    try! realm.write({
      oldGoals.category =  newGoals.category
      
    })
  }
}

class Category: Object {
  @Persisted var category: String
  
  convenience init(category: String) {
    self.init()
    self.category = category
  }
}
