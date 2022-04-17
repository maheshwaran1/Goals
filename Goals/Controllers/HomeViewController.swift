//
//  ViewController.swift
//  Goals
//
//  Created by mahesh on 3/19/22.
//  Copyright © 2022 MAHESHWARAN. All rights reserved.

import UIKit
import FirebaseAuth
import GoogleSignIn
import JGProgressHUD

class HomeViewController: UIViewController {
  
  //Refresh
  let refreshControl = UIRefreshControl()
  private let spinner = JGProgressHUD(style: .light)
  //collection
  var favorite = [Int]()
  private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  var data = [Category]()
  var notionAPIResultData = [Results]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Goals"
    collection()
    refresh()
    //Navigation Bar: - Add New Goals
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(didTapSignOut))
    navigationItem.rightBarButtonItem?.tintColor = .systemPink
    //Notion Data
    getCollectionDataFromAPI()
  }
  //MARK: - Collection
  private func collection() {
    view.addSubview(collectionView)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.isUserInteractionEnabled = true
    collectionView.backgroundColor = .tertiarySystemBackground
    collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
  }
  //MARK: - Refresh
  private func refresh() {
    //refresh
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.tintColor = .link
    refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    collectionView.alwaysBounceVertical = true
    collectionView.refreshControl = refreshControl
  }
  
  //MARK: - GET Notion API Data
  public func getCollectionDataFromAPI() {
    NotionAPI.shared.getCollectionAPIData {[weak self] result in
      switch result {
      case .success(let notionData):
        self?.notionAPIResultData = notionData
        self?.data = notionData.compactMap({
          Category( category: $0.properties.Category.rich_text.first?.text.content ?? "")
        })
        DispatchQueue.main.async {
          self?.collectionView.reloadData()
        }
      case .failure(let error):
        print(error)
      }
    }
  }
  @objc func refresh(_ sender: AnyObject) {
    //refresh
    DispatchQueue.main.async {
      self.collectionView.reloadData()
      self.getCollectionDataFromAPI()
      self.refreshControl.endRefreshing()
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //Realm - Data Retrive
    data = CategoryDatabase.shared.getAllContent()
    getCollectionDataFromAPI()
    collectionView.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //SignIn
    validateAuth()
    createNewCollection()
  }
  //MARK: - Create New Collection
  func createNewCollection() {
    //toolbar
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
    let createGoals = UIBarButtonItem(title: "Create New Goals", style: .plain, target: self, action: #selector(didTapCreate))
    let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
    let arr: [Any] = [flexibleSpace,createGoals,flexibleSpace1]
    setToolbarItems(arr as? [UIBarButtonItem] ?? [UIBarButtonItem](), animated: true)
    collectionView.reloadData()
  }
  
  //MARK: - Add New Goals
  @objc private func didTapCreate(){
    addNewCollection()
  }
  
  //MARK: - User Validation - Login / Sign Up
  private func validateAuth() {
    if FirebaseAuth.Auth.auth().currentUser == nil {
      let vc = LoginViewController()
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .fullScreen
      present(nav, animated: false)
    }
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
  }
  //MARK: - SignOut
  @objc private func didTapSignOut() {
    presentActionSheet()
  }
}
//MARK: - Logout
extension HomeViewController {
  func presentActionSheet(){
    let actionSheet = UIAlertController(title: "Sign Out", message: "Are you Sure want to Sign Out", preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: "Cancel",
                                        style: .cancel,
                                        handler: nil))
    actionSheet.addAction(UIAlertAction(title: "View Settings",
                                        style: .default,
                                        handler: { [weak self]  _ in
      self?.presentSettings()
    }))
    actionSheet.addAction(UIAlertAction(title: "SignOut",
                                        style: .destructive,
                                        handler: {[weak self] _ in
      self?.presentSignOut()
    }))
    present(actionSheet, animated: true)
  }
  //present User profile
  func presentSettings(){
    let vc = ProfileViewController()
    vc.title = "Settings"
    navigationController?.pushViewController(vc, animated: true)
  }
  func presentSignOut(){
    //google SignOut
    GIDSignIn.sharedInstance.signOut()
    do {
      //delete data - Database
      RealmDatabase.shared.deleteAllContent()
      try FirebaseAuth.Auth.auth().signOut()
      let vc = LoginViewController()
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .fullScreen
      self.present(nav, animated: true)
    }
    catch {
      print("Failed to Sign Out")
    }
  }
}

// MARK: - Collection View
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as! CustomCollectionViewCell
    cell.contentView.layer.cornerRadius = 8
    cell.configure(with: data[indexPath.row], label: data[indexPath.row])
    cell.contentView.backgroundColor = .tertiarySystemBackground
    cell.contentView.layer.borderWidth = 0.1
    cell.contentView.layer.borderColor = .none
    return cell
  }
  //MARK: UICollectionViewDelegateFlowLayout
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (view.frame.size.width/3)-5, height: (view.frame.size.width/3)-5)
    //return CGSize(width: (view.frame.size.width/2)-3, height: (view.frame.size.width/2)-3)
    //return CGSize(width: (view.frame.size.width/3), height: (view.frame.size.width/3))
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 2
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 2
  }
  //section
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
  }
  //MARK: - Custom Menus
  func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
    let content = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {[weak self] _ in
      //MARK: - Favorite
      let favorite = UIAction(title: self?.favorite.contains(indexPath.row) == true ? "Remove Favorite":"Favorite",image: self?.favorite.contains(indexPath.row) == true ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"), identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
        
        if self?.favorite.contains(indexPath.row) == true{
          self?.favorite.removeAll(where: { $0 == indexPath.row})
        } else {
          self?.favorite.append(indexPath.row)
        }
      }
      //MARK: - Edit
      let edit = UIAction(title: "Update", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
        let addNewGoals = UIAlertController(title:  "Update Collection", message:  "Please Update your Goal", preferredStyle: .alert)
        //Category
        addNewGoals.addTextField { category in
          category.placeholder =  self?.data[indexPath.row].category //"Enter your Category"
          category.becomeFirstResponder()
        }
        //save
        let save = UIAlertAction(title:  "Update" , style: .default) { [self] _ in
          if let category = addNewGoals.textFields?.first?.text, let oldData = self?.data[indexPath.row] {
            let create = Category(category: category)
            self?.data[indexPath.row] = create
            CategoryDatabase.shared.updateContentToRealm(oldGoals: oldData, newGoals: create)
            self?.collectionView.reloadData()
          }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        addNewGoals.addAction(save)
        addNewGoals.addAction(cancel)
        self?.present(addNewGoals,animated: true)
      }
      //MARK: - Add
      let add = UIAction(title: "Create", image: UIImage(systemName: "plus"), identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
        self?.addNewCollection()
      }
      //MARK: - Delete
      let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil ,discoverabilityTitle: nil, attributes: .destructive, state: .off) { _ in
        //        if let deleteData = self?.data[indexPath.row] {
        //          CategoryDatabase.shared.deleteContentToRealm(newGoals: deleteData)
        //        }
        self?.data.remove(at: indexPath.row)
        self?.collectionView.reloadData()
      }
      return UIMenu(title: "", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [favorite,edit,delete,add])
    }
    collectionView.reloadData()
    return content
  }
  //MARK: - UserInterAction
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = GoalsViewController()
    vc.title = data[indexPath.row].category
    navigationController?.pushViewController(vc, animated: true)
  }
}
// MARK: - Alert : Create New Collection View
extension HomeViewController {
  func addNewCollection() {
    let addNewGoals = UIAlertController(title:  "Add New Collection", message:  "Please Enter your Goals", preferredStyle: .alert)
    //Category
    addNewGoals.addTextField { category in
      category.placeholder =  "Enter your Category"
      category.becomeFirstResponder()
    }
    //save
    let save = UIAlertAction(title:  "Save" , style: .default) { [self] _ in
      if let category = addNewGoals.textFields?.first?.text {
        let create = Category(category: category)
        self.data.append(create)
        CategoryDatabase.shared.saveContentToRealm(newGoals: create)
        self.collectionView.reloadData()
      }
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    addNewGoals.addAction(save)
    addNewGoals.addAction(cancel)
    present(addNewGoals,animated: true)
  }
}
