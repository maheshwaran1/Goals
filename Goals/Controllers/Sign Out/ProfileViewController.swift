//
//  ProfileViewController.swift
//  Goals
//
//  Created by mahesh on 3/19/22.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import SDWebImage

final class ProfileViewController: UIViewController {
  // Table View
  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SignOut")
    return tableView
  }()
  var data = [ProfileViewModel]()
  override func viewDidLoad() {
    super.viewDidLoad()
    //Title
    navigationItem.largeTitleDisplayMode = .always
    view.backgroundColor = .systemBackground
    tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
    //Table
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    //SignOut Buuton
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(didTapSignOut))
    navigationItem.rightBarButtonItem?.tintColor = .systemPink
    tableView.tableHeaderView = createTableHeader()
    //info
    data.append(ProfileViewModel(viewModelType: .info, title: "Name :  \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")", handler: nil))
    data.append(ProfileViewModel(viewModelType: .info, title: "Email :  \(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")", handler: nil))
  }
  //MARK: - Profile Picture
  func createTableHeader() -> UIView? {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return nil
    }
    let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
    let filename = safeEmail + "_profile_picture.png"
    let path = "images/" + filename
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
    headerView.backgroundColor = .systemBackground
    let imageView = UIImageView(frame: CGRect(x: (view.width-150)/2, y: 75, width: 150, height: 150))
    imageView.contentMode = .scaleAspectFill
    imageView.layer.borderColor = UIColor.systemPink.cgColor
    imageView.layer.borderWidth = 3
    imageView.layer.masksToBounds = true
    //imageView.backgroundColor = .systemBackground
    imageView.layer.cornerRadius = imageView.width/2
    headerView.addSubview(imageView)
    StorageManager.shared.downloadURL(for: path, completion: { result in
      switch result {
      case .success(let url):
        //self?.downloadImage(imageView: imageView, url: url)
        imageView.sd_setImage(with: url, completed: nil)
      case .failure(let error):
        print("Failed to get Download url: \(error)")
      }
    })
    return headerView
  }
  /*
   //download Image
   func downloadImage(imageView: UIImageView, url: URL) {
   URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
   guard let data = data, error == nil else {
   return
   }
   DispatchQueue.main.async {
   let image = UIImage(data: data)
   imageView.image = image
   }
   }).resume()
   }
   */
  // Navigation Item
  @objc private func didTapSignOut() {
    //actionSheet
    let actionSheet = UIAlertController(title: "Sign Out", message: "Are you want to Log out the Session", preferredStyle: .actionSheet)
    //Action
    actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self]_ in
      guard let strongSelf = self else {
        return
      }
      //Clear caches out after log out
      UserDefaults.standard.setValue(nil, forKey: "email")
      UserDefaults.standard.setValue(nil, forKey: "name")
      //google SignOut
      GIDSignIn.sharedInstance.signOut()
      do {
        //delete data - Database
        RealmDatabase.shared.deleteAllContent()
        
        try FirebaseAuth.Auth.auth().signOut()
        let vc = LoginViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        strongSelf.present(nav, animated: true)
      }
      catch {
        print("Failed to Sign Out")
      }
    }))
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(actionSheet,animated:  true)
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let viewModel = data[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
    cell.setUp(with: viewModel)
    return cell
  }
}

class ProfileTableViewCell: UITableViewCell {
  static let identifier = "ProfileTableViewCell"
  public func setUp(with viewModel: ProfileViewModel){
    //title
    textLabel?.text = viewModel.title
    switch viewModel.viewModelType {
    case .info:
      textLabel?.textAlignment = .left
      textLabel?.font = UIFont(name: "Tahoma", size: 20)
      selectionStyle = .none
    }
  }
}
