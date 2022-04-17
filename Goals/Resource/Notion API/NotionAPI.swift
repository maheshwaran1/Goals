//
//  NotionAPI.swift
//  Goals
//
//  Created by MAHESHWARAN on 22/03/22.
//

import Foundation

final class NotionAPI {
  //singleton
  static let shared = NotionAPI()
  
  struct Constants {
    static let databaseID = "ebdd41f8-a830-4e45-a06b-b0bf637f9757"
    static let bearerToken = "Bearer secret_UlauLEYuq7GyKjVFSlR6hLpuujiqlri1pELlNlRBL0W"
    static let header = [
      "Authorization" : "Bearer secret_UlauLEYuq7GyKjVFSlR6hLpuujiqlri1pELlNlRBL0W",
      "Accept": "application/json",
      "Notion-Version": "2022-02-22",
      "Content-Type": "application/json"
    ]
  }
  //MARK: - GET Notion API Data
  public func getNotionAPIData(category: String,completion: @escaping (Result<[Results], Error>) -> Void){
    
    var request = URLRequest(url: URL(string: "https://api.notion.com/v1/databases/ebdd41f8a8304e45a06bb0bf637f9757/query")! as URL,
                             cachePolicy: .useProtocolCachePolicy,
                             timeoutInterval: 10.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = Constants.header
    let jsonFilterData = [ "filter": ["property": "Category","rich_text": ["equals": category]]]
    let jsonData = try! JSONSerialization.data(withJSONObject: jsonFilterData, options: .fragmentsAllowed)
    request.httpBody = jsonData as Data
    let task = URLSession.shared.dataTask(with: request) { data, _ , error in
      if let error = error {
        completion(.failure(error))
      }
      else if let data = data {
        do {
          let result = try JSONDecoder().decode(NotionGet.self, from: data)
          completion(.success(result.results))
        }
        catch {
          completion(.failure(error))
        }
      }
    }
    task.resume()
  }
  //MARK: - Collection View Notion Data
  public func getCollectionAPIData(completion: @escaping (Result<[Results], Error>) -> Void){
    
    var request = URLRequest(url: URL(string: "https://api.notion.com/v1/databases/ebdd41f8a8304e45a06bb0bf637f9757/query")! as URL,
                             cachePolicy: .useProtocolCachePolicy,
                             timeoutInterval: 10.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = Constants.header
    let task = URLSession.shared.dataTask(with: request) { data, _ , error in
      if let error = error {
        completion(.failure(error))
      }
      else if let data = data {
        do {
          let result = try JSONDecoder().decode(NotionGet.self, from: data)
          completion(.success(result.results))
        }
        catch {
          completion(.failure(error))
        }
      }
    }
    task.resume()
  }
  //MARK: - POST Notion API
  public func sendDataToNotionAPI(category: String, title: String, tags: String, completion: @escaping (Bool) -> Void) {
    let parameters = [
      "parent": ["database_id": Constants.databaseID],
      "properties": [
        "Category": ["rich_text" : [["text":["content": category]]]],
        "Title": ["title" : [["text":["content": title]]]],
        "Tags": ["type": "select","select": ["name": tags]]
      ]] as [String : Any]
    
    let postData = try! JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
    
    let request = NSMutableURLRequest(url: NSURL(string: "https://api.notion.com/v1/pages")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 10.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = Constants.header
    request.httpBody = postData as Data
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
      guard let data = data, error == nil else {
        print("Error")
        return
      }
      do {
        try JSONSerialization.jsonObject(with: data,options: .fragmentsAllowed)
        completion(true)
      }
      catch {
        print("Error in Json")
        completion(false)
      }
    })
    task.resume()
  }
  
  //MARK: - PATCH
  public func updateDataToNotionAPI(category: String, title: String, tags: String, completion: @escaping (Bool) -> Void) {
    let parameters = [
      "parent": ["database_id": Constants.databaseID],
      "properties": [
        "Category": ["rich_text" : [["text":["content": category]]]],
        "Title": ["title" : [["text":["content": title]]]],
        "Tags": ["type": "select","select": ["name": tags]]
      ]] as [String : Any]
    
    let postData = try! JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
    
    let request = NSMutableURLRequest(url: NSURL(string: "https://api.notion.com/v1/databases/ebdd41f8a8304e45a06bb0bf637f9757")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 10.0)
    request.httpMethod = "PATCH"
    request.allHTTPHeaderFields = Constants.header
    request.httpBody = postData as Data
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
      guard let data = data, error == nil else {
        print("Error")
        return
      }
      do {
        try JSONSerialization.jsonObject(with: data,options: .fragmentsAllowed)
        completion(true)
      }
      catch {
        print("Error in Json")
        completion(false)
      }
    })
    task.resume()
  }
}
