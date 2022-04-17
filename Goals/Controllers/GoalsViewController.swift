//
//  GoalsViewController.swift
//  Goals
//
//  Created by mahesh on 3/19/22.
//  Copyright © 2022 MAHESHWARAN. All rights reserved.

import UIKit
import RxSwift
import RxCocoa
import JGProgressHUD
import RxDataSources

class GoalsViewController: UIViewController, UIScrollViewDelegate {
  
  //refresh
  let refreshControl = UIRefreshControl()
  //Add Goals
  var newGoals = [Goals]()
  //Category
  var data = [Category]()
  // Table View
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: self.view.frame, style: .insetGrouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(GoalsTableViewCell.self, forCellReuseIdentifier: "GoalsTableViewCell")
    tableView.separatorColor = .systemBlue
    return tableView
  }()
  //RxSwift
  var bag = DisposeBag()
  var users = BehaviorSubject(value: [Goals]())
  var viewModel = Model()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    //Navigation Bar: - Add New Goals
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Goals", style: .done, target: self, action: #selector(didTapAddGoals))
    navigationItem.rightBarButtonItem?.tintColor = .systemPink
    //Table
    view.addSubview(tableView)
    data = CategoryDatabase.shared.getAllContent()
    viewModel.newGoals = RealmDatabase.shared.getAllContent()
    refresh()
    // RxSwift
    bindTableView()
    viewModel.fetchUsers(category: self.title ?? "")
    
  }
  
  //MARK: - refresh
  private func refresh() {
    //refresh
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.tintColor = .link
    refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    tableView.addSubview(refreshControl)
  }
  @objc func refresh(_ sender: AnyObject) {
    //refresh
    DispatchQueue.main.async {
      self.viewModel.fetchUsers(category: self.title ?? "")
      self.data = CategoryDatabase.shared.getAllContent()
      self.viewModel.newGoals = RealmDatabase.shared.getAllContent()
      self.tableView.reloadData()
      self.refreshControl.endRefreshing()
    }
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  //MARK: -  Add Goals
  @objc private func didTapAddGoals() {
    add_EditGoals(isAdd: true)
  }
  //MARK: - Add Goals
  func add_EditGoals(isAdd: Bool,index: Int = 0){
    
    let add_editGoals = UIAlertController(title: isAdd ? "Create Goals" : "Edit Goals", message: isAdd ? "Choose your Goals" : "Edit your Goals", preferredStyle: .alert)
    add_editGoals.addTextField{ textField in
      textField.borderStyle = .roundedRect
      textField.placeholder = "Choose your Title"
    }
    add_editGoals.addTextField{ tags in
      // Implement PickerView delegates
      let pickerView = UIPickerView()
      pickerView.dataSource = self
      pickerView.delegate = self
      pickerView.tag = 1
      let toolbar = UIToolbar()
      toolbar.barStyle = UIBarStyle.default
      toolbar.isTranslucent = true
      tags.inputAccessoryView = toolbar
      tags.borderStyle = .roundedRect
      tags.font = .systemFont(ofSize: 15)
      tags.tag = 1
      tags.inputView = pickerView
      // Save the textField to assign values
      self.textFieldPicker = tags
      tags.placeholder =  "Tag: #Goals #Personal #Plans"
    }
    
    //save
    let save = UIAlertAction(title: isAdd ? "Save" : "Update", style: .default) { [self] _ in
      if let titleText = add_editGoals.textFields?.first?.text, let tags = add_editGoals.textFields?[1].text {
        let data = title ?? ""
        let goals = Goals(category: data, title: titleText, tags: tags)
        //Add new Goals
        if isAdd {
          self.viewModel.newGoals.append(goals)
          self.viewModel.addUser(user: goals, category: data, title: titleText, tags: tags)
          self.tableView.reloadData()
        }
        //Edit
        else {
          self.viewModel.newGoals[index] = goals
          RealmDatabase.shared.updateContentToRealm(oldGoals: self.viewModel.newGoals[index], newGoals: goals)
          self.viewModel.editUser(category: data, title: titleText, tags: tags, index: index)
          self.tableView.reloadData()
        }
        
        
      }
    }
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
    
    add_editGoals.addAction(cancel)
    add_editGoals.addAction(save)
    
    present(add_editGoals,animated: true)
    
  }
  
  //MARK: - Edit Goals
  //Picker View
  var textFieldPicker: UITextField?
  
}
// MARK: - Picker View (Create Goals)
extension GoalsViewController : UIPickerViewDelegate,UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    //
    if pickerView.tag == 1{
      return viewModel.tags.count
    }else {
      return  data.count
    }
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView.tag == 1{
      return viewModel.tags[row]
    } else {
      return  data[row].category
    }
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView.tag == 1 {
      textFieldPicker?.text = viewModel.tags[row]
    } else {
      textFieldPicker?.text = data[row].category
    }
  }
}

//MARK: - Row Height
extension GoalsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //MARK: - MOVE
    let move = UIContextualAction(style: .normal, title: "Move") { [self] _, _, _ in
      //actionSheet
      tableView.deselectRow(at: indexPath, animated: true)
      
      let action = UIAlertController(title: "Copy", message: "Do you Want to Change the Goals Category", preferredStyle: .alert)
      
      action.addTextField{ move in
        // Implement PickerView delegates
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tag = 2
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        move.inputAccessoryView = toolbar
        move.borderStyle = .roundedRect
        move.inputView = pickerView
        move.font = .systemFont(ofSize: 15)
        // Save the textField to assign values
        self.textFieldPicker = move
        move.placeholder =  self.viewModel.newGoals[indexPath.row].category
      }
      let save = UIAlertAction(title:  "Copy", style: .default) { [self] _ in
        
        if let category = action.textFields?.first?.text{
          let goals = Goals( category: category, title: self.viewModel.newGoals[indexPath.row].title, tags: self.viewModel.newGoals[indexPath.row].tags)
          
          RealmDatabase.shared.updateContentToRealm(oldGoals: self.viewModel.newGoals[indexPath.row], newGoals: goals)
          self.viewModel.newGoals[indexPath.row] = goals
          
          NotionAPI.shared.sendDataToNotionAPI(category: category, title: self.viewModel.newGoals[indexPath.row].title, tags: self.viewModel.newGoals[indexPath.row].tags) { success in
            if success {
              print("Data Edited To Notion API")
            }
            else {
              print("Failed to send Data")
            }
          }
          
          //self.newGoals.remove(at: indexPath.row)
          self.viewModel.newGoals.remove(at: indexPath.row)
          self.tableView.reloadData()
        }
      }
      
      let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
      action.addAction(cancel)
      action.addAction(save)
      self.present(action,animated:  true)
    }
    
    tableView.reloadData()
    move.backgroundColor = .systemBlue
    //swipe
    let swipe = UISwipeActionsConfiguration(actions: [move])
    return swipe
  }
}

//MARK: - RxSwift
extension GoalsViewController{
  
  func bindTableView() {
    tableView.rx.setDelegate(self).disposed(by: bag)
    //MARK: - Row Count
    viewModel.users.bind(to: tableView.rx.items(cellIdentifier: "GoalsTableViewCell", cellType: GoalsTableViewCell.self)) { row, item, cell in
      cell.configure(title: item.title, tags: item.tags)
    }.disposed(by: bag)
    
    //MARK: - Selected
    tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexpath in
      self?.tableView.deselectRow(at: indexpath, animated: true)
      self?.add_EditGoals(isAdd: false,index: indexpath.row)
    }).disposed(by: bag)
    
    
    //MARK: -Delete
    tableView.rx.itemDeleted.subscribe(onNext:{[weak self]indexPath in
      guard let self = self else {return}
      self.viewModel.deleteUser(index: indexPath.row)
    }).disposed(by: bag)
  }
  
  
}
