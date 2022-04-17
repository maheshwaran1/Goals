//
//  DatabaseManager.swift
//  Goals
//
//  Created by mahesh on 3/19/22.
//
import UIKit
import FirebaseDatabase

final class DatabaseManager {  
  //singleton
  static let shared = DatabaseManager()
  
  private let database = Database.database().reference()
  static func safeEmail(emailAddress: String) -> String {
    var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    return safeEmail
  }
}
//MARK: - New User
extension DatabaseManager {
  public func userExists(with email: String, completion: @escaping ((Bool)->Void)){
    let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
    database.child(safeEmail).observeSingleEvent(of: .value,with: { snapshot in
      guard snapshot.value as? String != nil else {
        completion(false)
        return
      }
      completion(true)
    })
    
  }
  //MARK: - Insert new User
  public func insertUser(with user: GoalsAppUser, completion: @escaping (Bool)->Void) {
    database.child(user.safeEmail).setValue([
      "first_name": user.firstName,
      "last_name": user.lastName
    ],withCompletionBlock: { error, _ in
      guard error == nil else {
        print("Failed to Write to Database")
        completion(false)
        return
      }
      completion(true)
    })
  }
}

extension DatabaseManager {
  // Returns dictionary node at child path
  public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
    database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
      guard let value = snapshot.value else {
        completion(.failure(DatabaseError.failedToFetch))
        return
      }
      completion(.success(value))
    }
  }
}

public enum DatabaseError: Error {
  case failedToFetch
  public var localizedDescription: String {
    switch self {
    case .failedToFetch:
      return "This means failed something"
    }
  }
}

struct GoalsAppUser {
  let firstName: String
  let lastName: String
  let emailAddress: String
  
  //computed Property
  var safeEmail: String {
    var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    return safeEmail
  }
  var profilePictureFileName: String {
    return "\(safeEmail)_profile_picture.png"
  }
}
