//
//  RegisterViewController.swift
//  Goals
//
//  Created by mahesh on 3/19/22.
//

import UIKit
import FirebaseAuth
import Firebase
import JGProgressHUD

class RegisterViewController: UIViewController {
  
  //Spinner
  private let spinner = JGProgressHUD(style: .dark)
  //scrollView
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.clipsToBounds = true
    return scrollView
  }()
  //image view
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "person.circle")
    imageView.tintColor = .darkGray
    imageView.contentMode = .scaleAspectFit
    //circle the image
    imageView.layer.masksToBounds = true
    //border
    imageView.layer.borderWidth = 2
    imageView.layer.borderColor = UIColor.lightGray.cgColor
    return imageView
  }()
  //First name
  private let firstNameField: UITextField = {
    let field = UITextField()
    field.autocapitalizationType = .none
    field.autocorrectionType = .no
    field.returnKeyType = .continue
    //border
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.placeholder = " First Name"
    //border for email
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .secondarySystemBackground
    return field
  }()
  // Last Name
  private let lastNameField: UITextField = {
    let field = UITextField()
    field.autocapitalizationType = .none
    field.autocorrectionType = .no
    field.returnKeyType = .continue
    //border
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.placeholder = " Last Name"
    //border for email
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .secondarySystemBackground
    return field
  }()
  //Email Field
  private let emailField: UITextField = {
    let field = UITextField()
    field.autocapitalizationType = .none
    field.autocorrectionType = .no
    field.returnKeyType = .continue
    //border
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.placeholder = " Email Address"
    //border for email
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .secondarySystemBackground
    return field
  }()
  //Password Field
  private let passwordField: UITextField = {
    let field = UITextField()
    field.autocapitalizationType = .none
    field.autocorrectionType = .no
    field.returnKeyType = .done
    //border
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.placeholder = " Password"
    //border for email
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .secondarySystemBackground
    field.isSecureTextEntry = true
    return field
  }()
  //login buton
  private let registerButton: UIButton = {
    let button = UIButton()
    button.setTitle(" Register", for: .normal)
    button.backgroundColor = .systemGreen
    //title color
    button.setTitleColor(.white, for: .normal)
    //icon
    button.setImage(UIImage(systemName: "paperplane.circle"), for: .normal)
    button.tintColor = .white
    button.layer.cornerRadius = 12
    button.layer.masksToBounds = true
    button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = "Create Account"
    //Title
    navigationController?.navigationBar.prefersLargeTitles = true
    //navigationItem.largeTitleDisplayMode = .always    
    //add target to login button
    registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    
    emailField.delegate = self
    passwordField.delegate = self
    
    //Add Subviews
    //scrollview
    view.addSubview(scrollView)
    //imageview
    scrollView.addSubview(imageView)
    //first name
    scrollView.addSubview(firstNameField)
    //last name
    scrollView.addSubview(lastNameField)
    scrollView.addSubview(emailField)
    scrollView.addSubview(passwordField)
    
    scrollView.addSubview(registerButton)
    
    //MARK: touch recognizer to change image for profile
    imageView.isUserInteractionEnabled = true
    scrollView.isUserInteractionEnabled = true
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
    gesture.numberOfTouchesRequired = 1
    
    imageView.addGestureRecognizer(gesture)
  }
  
  //func didTapChangeProfilePic
  @objc private func didTapChangeProfilePic(){
    presentPhotoActionSheet()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.frame = view.bounds
    let size = scrollView.width/3
    //image
    imageView.frame = CGRect(x: (scrollView.width - size)/2,
                             y: 20,
                             width: size,
                             height: size)
    imageView.layer.cornerRadius = imageView.width/2.0
    //First Name
    firstNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
    //Last Name
    lastNameField.frame = CGRect(x: 30,
                                 y: firstNameField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 52)
    //email
    emailField.frame = CGRect(x: 30,
                              y: lastNameField.bottom + 10,
                              width: scrollView.width - 60,
                              height: 52)
    //Password
    passwordField.frame = CGRect(x: 30,
                                 y: emailField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 52)
    //LoginButton
    registerButton.frame = CGRect(x: 30,
                                  y: passwordField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
  }
  
  //MARK: - Register Button
  @objc private func registerButtonTapped(){
    firstNameField.resignFirstResponder()
    lastNameField.resignFirstResponder()
    emailField.resignFirstResponder()
    passwordField.resignFirstResponder()
    guard let firstName = firstNameField.text, let lastName = lastNameField.text,let email = emailField.text, let password = passwordField.text,!firstName.isEmpty,!lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count>=6 else {
      alertUserRegisterError()
      return
    }
    //spinner
    spinner.show(in: view)
    
    //User Already Exists in Database
    DatabaseManager.shared.userExists(with: email,completion:  {[weak self] exists in
      
      guard let strongSelf = self else {
        return
      }
      DispatchQueue.main.async {
        strongSelf.spinner.dismiss()
      }
      
      guard !exists else {
        //Alert
        strongSelf.alertUserRegisterError(message: "User Already Exists")
        return
      }
      
      //Create New Users
      FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
        guard authResult != nil, error == nil else {
          print("Error: Creating Account")
          return
        }
        //User Cache
        UserDefaults.standard.setValue(email, forKey: "email")
        UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
        
        //Save Data in Database
        
        let goalUser = GoalsAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
        
        DatabaseManager.shared.insertUser(with: goalUser,completion: { success in
          if success {
            //Upload image
            guard let image = strongSelf.imageView.image, let data = image.pngData() else {
              return
            }
            //fileName
            let filename = goalUser.profilePictureFileName
            StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
              switch result {
              case .success(let downloadUrl):
                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                print(downloadUrl)
              case .failure(let error):
                print("Storage Manager Error \(error)")
              }
              
            })
          }
        })
        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        
      })
    })
  }
  
  //Alert
  func alertUserRegisterError(message: String = "Please Enter, Correct information for Register") {
    let alert = UIAlertController(title: "Register Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    present(alert, animated: true)
  }
  
}

extension RegisterViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailField {
      passwordField.becomeFirstResponder()
    } else if textField == passwordField {
      registerButtonTapped()
    }
    return true
  }
}


//MARK: - profile picture
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func presentPhotoActionSheet(){
    let actionSheet = UIAlertController(title: "Profile Picture", message: "Choose your Field and Select a Picture", preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: "Cancel",
                                        style: .cancel,
                                        handler: nil))
    actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                        style: .default,
                                        handler: { [weak self]  _ in
      self?.presenCamera()
    }))
    actionSheet.addAction(UIAlertAction(title: "Choose Photo Library",
                                        style: .default,
                                        handler: {[weak self] _ in
      self?.presentPhotPicker()
    }))
    present(actionSheet, animated: true)
  }
  
  //update image to profile
  func presenCamera(){
    let vc = UIImagePickerController()
    vc.sourceType = .camera
    vc.delegate = self
    vc.allowsEditing = true
    present(vc, animated: true)
  }
  
  func presentPhotPicker(){
    let vc = UIImagePickerController()
    vc.sourceType = .photoLibrary
    vc.delegate = self
    vc.allowsEditing = true
    present(vc, animated: true)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
      return
    }
    
    imageView.image = selectedImage
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}


