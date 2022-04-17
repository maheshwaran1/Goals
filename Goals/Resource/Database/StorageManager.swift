//
//  StorageManager.swift
//  Goals
//
//  Created by mahesh on 3/19/22.
//

import Foundation
import FirebaseStorage

class StorageManager {
  
  static let shared = StorageManager()
  
  private let storage = Storage.storage().reference()
  
  //Upload Picture to Firebase Storage
  public typealias UploadPictureCompletion = (Result<String, Error>)-> Void
  
  public func uploadProfilePicture(with data: Data,fileName: String, completion: @escaping UploadPictureCompletion){
    
    storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {[weak self] metadata, error in
      guard let strongSelf = self else {
        return
      }
      guard error == nil else{
        //failed
        print("failed to upload data to database")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }
      strongSelf.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
        guard let url = url else {
          print("Failed to get download url")
          completion(.failure(StorageErrors.failedToGetDownloadUrl))
          return
        }
        let urlString = url.absoluteString
        print("download url returned: \(urlString)")
        completion(.success(urlString))
      })
    })
    
  }
  
  public enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDownloadUrl
  }
  
  //Download Image
  public func downloadURL(for path: String,  completion:@escaping (Result<URL, Error>)-> Void){
    let reference = storage.child(path)
    reference.downloadURL(completion: {url, error in
      guard let url = url, error == nil else {
        completion(.failure(StorageErrors.failedToGetDownloadUrl))
        return
      }
      completion(.success(url))
    })
  }
}
