//
//  LoginViewController.swift
//  Goals
//
//  Created by mahesh on 3/19/22.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
  
  //spinner
  private let spinner = JGProgressHUD(style: .dark)
  //scrollView
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.clipsToBounds = true
    return scrollView
  }()
  //imageView
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "logo")
    imageView.contentMode = .scaleAspectFit
    return imageView
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
  private let loginButton: UIButton = {
    let button = UIButton()
    button.setTitle(" Sign In", for: .normal)
    button.backgroundColor = .link
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
  
  
  //Google
  private let googleLoginButton = GIDSignInButton()
  private var loginObserver: NSObjectProtocol?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .tertiarySystemGroupedBackground
    title = "Sign In"
    //Title
    navigationController?.navigationBar.prefersLargeTitles = true
    //navigationItem.largeTitleDisplayMode = .always
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: " Register", style: .done, target: self, action: #selector(didTapRegister))
    //add target to login button
    loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    
    //add Target to Google Login Button
    googleLoginButton.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
    
    emailField.delegate = self
    passwordField.delegate = self
    
    //Add Subviews
    view.addSubview(scrollView)
    scrollView.addSubview(imageView)
    scrollView.addSubview(emailField)
    scrollView.addSubview(passwordField)
    scrollView.addSubview(loginButton)
    scrollView.addSubview(googleLoginButton)
    
    //GoogleSign()
    loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
      guard let strongSelf = self else {
        return
      }
      
      strongSelf.navigationController?.dismiss(animated: true, completion: nil)
    })
  }
  deinit {
    if let observer = loginObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }
  
  // Navigation Item
  @objc private func didTapRegister() {
    let vc = RegisterViewController()
    vc.title = "Create Account"
    navigationController?.pushViewController(vc, animated: true)
  }
  //googleLoginButtonTapped
  @objc private func googleLoginButtonTapped() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
          let signInConfig = appDelegate.signInConfig else {
      return
    }
    GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
      guard let user = user, error == nil else { return }
      appDelegate.handleSessionRestore(user: user)
    }
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
    //email
    emailField.frame = CGRect(x: 30,
                              y: imageView.bottom + 10,
                              width: scrollView.width - 60,
                              height: 52)
    //Password
    passwordField.frame = CGRect(x: 30,
                                 y: emailField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 52)
    //LoginButton
    loginButton.frame = CGRect(x: 30,
                               y: passwordField.bottom + 10,
                               width: scrollView.width - 60,
                               height: 52)
    //googleLoginButton
    googleLoginButton.frame = CGRect(x: 30,
                                     y: loginButton.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
    googleLoginButton.frame.origin.y = loginButton.bottom+20
  }
  
  //MARK: - Login Button
  @objc private func loginButtonTapped(){
    
    emailField.resignFirstResponder()
    passwordField.resignFirstResponder()
    guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count>=6 else {
      alertUserLoginError()
      return
    }
    //spinner
    spinner.show(in: view)
    
    //Firebase Login
    FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in
      guard let strongSelf = self else {
        return
      }
      //spinner
      DispatchQueue.main.async {
        strongSelf.spinner.dismiss()
      }
      guard let result = authResult, error == nil else {
        print("Failed to log in useer with email: \(email)")
        return
      }
      let user = result.user
      
      let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
      DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
        
        switch result {
        case .success(let data):
          guard let userData = data as? [String: Any],
                let firstName = userData["first_name"] as? String,
                let lastName = userData["last_name"] as? String else {
            return
          }
          UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
          
        case .failure(let error):
          print("Failed to read data with error \(error)")
        }
      })
      //cache user Details
      UserDefaults.standard.set(email, forKey: "email")
      
      print("SignIn Success \(user)")
      strongSelf.navigationController?.dismiss(animated: true, completion: nil)
    })
  }
  //MARK: - Alert
  func alertUserLoginError() {
    let alert = UIAlertController(title: "Login Error", message: "Please Enter your Correct Information for Login", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    present(alert, animated: true)
  }
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailField {
      passwordField.becomeFirstResponder()
    } else if textField == passwordField {
      loginButtonTapped()
    }
    return true
  }
}


