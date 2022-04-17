//
//  GoalsTableViewCellViewModel.swift
//  Goals
//
//  Created by MAHESHWARAN on 22/03/22.
//

import UIKit
import RealmSwift

class GoalsTableViewCell: UITableViewCell {
  
  static let identifier = "GoalsTableViewCell"
  //title
    let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    //label.font = UIFont(name: "Tahoma",size: 14)
    label.textAlignment = .left
    label.font = .systemFont(ofSize: 18, weight: .medium)
    return label
  }()
  //Tag Label
    let tagLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .left
    label.textColor = .link
    label.font = .systemFont(ofSize: 15, weight: .medium)
    return label
  }()
    
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .value1, reuseIdentifier: "item.id")
    contentView.addSubview(titleLabel)
    contentView.addSubview(tagLabel)
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    tagLabel.text = nil
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.frame = CGRect(x: contentView.left+5, y: 0, width: contentView.frame.size.width-10, height: contentView.frame.size.height-5) //contentView.bounds
    tagLabel.frame = CGRect(x: contentView.right-70, y: 0, width: contentView.frame.size.width-100, height: contentView.frame.size.height-5)
  }
  
  public func configure(title: String, tags: String){
    titleLabel.text = title
    tagLabel.text = tags
  }
}
