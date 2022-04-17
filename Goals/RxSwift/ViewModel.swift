//
//  ViewModel.swift
//  Goals
//
//  Created by MAHESHWARAN on 08/04/22.
//  Copyright © 2022 MAHESHWARAN. All rights reserved.

import UIKit
import Realm
import RxCocoa
import RxSwift
import RxDataSources

//MARK: - RxSwift - TableView

class Model  {
  var newGoals = [Goals]()
  var tags = ["Goals","Work","Personal","Plans","Holiday"]
  
  var users = BehaviorSubject(value: [Goals]())
  
  //MARK: - Fetch
  func fetchUsers(category: String) {
    NotionAPI.shared.getNotionAPIData(category: category) { result in
      switch result {
      case .success(let data):
        self.newGoals = data.compactMap({
          Goals(category: $0.properties.Category.rich_text.first?.text.content ?? "", title: $0.properties.Title.title.first?.text.content ?? "", tags: $0.properties.Tags.select.name)
        })
        self.users.on(.next(self.newGoals))
        
      case .failure(let error):
        print(error)
      }
    }
  }
  //MARK: - Add
  func addUser(user: Goals,category: String, title: String,tags: String){
    guard var users = try? users.value() else {return}
    users.insert(user, at: 0)
    //Database
    NotionAPI.shared.sendDataToNotionAPI(category: category, title: title, tags: tags) { success in
      if success {
        print("Data Add To Notion API")
      }
      else {
        print("Failed to send Data")
      }
    }
    RealmDatabase.shared.saveContentToRealm(newGoals: user)
    self.users.on(.next(users))
  }
  
  //MARK: - Delete
  func deleteUser(index: Int){
    guard var users = try? users.value() else {return}
    users.remove(at: index)
    self.newGoals.remove(at: index)
    self.users.on(.next(users))
  }
  //MARK: - Edit
  func editUser(category: String, title: String,tags: String,index: Int){
    guard let users = try? users.value() else {return}
    users[index].title = title
    users[index].tags = tags
    //Database
    NotionAPI.shared.sendDataToNotionAPI(category: category, title: title, tags: tags) { success in
      if success {
        print("Data Add To Notion API")
      }
      else {
        print("Failed to send Data")
      }
    }
    self.users.on(.next(users))
  }
  
  
}


