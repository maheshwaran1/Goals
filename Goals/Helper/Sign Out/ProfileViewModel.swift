//
//  ProfileViewModel.swift
//  Goals
//
//  Created by mahesh on 3/19/22.
//

import Foundation

enum ProfileViewModelType {
  case info
}

struct ProfileViewModel {
  let viewModelType: ProfileViewModelType
  let title: String
  let handler: (()-> Void)?
}

