//
//  CustomCollectionViewCell.swift
//  Goals
//
//  Created by mahesh on 3/19/22.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "CustomCollectionViewCell"
  
  private let myImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "photo.circle")
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.backgroundColor = .systemBackground
    return imageView
  }()
  private let myLabel: UILabel = {
    let myLabel = UILabel()
    myLabel.text = "Custom"
    //myLabel.font = UIFont(name: "Tahoma", size: 30)
    myLabel.font = .systemFont(ofSize: 20, weight: .bold)
    myLabel.textColor = .systemPink
    myLabel.textAlignment = .center
    return myLabel
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = .systemPink
    contentView.addSubview(myImageView)
    contentView.addSubview(myLabel)
    contentView.clipsToBounds = true
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    myLabel.frame = CGRect(x: 5, y: contentView.frame.size.height-35, width: contentView.frame.size.width-10, height: 50)
    myImageView.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width-5, height: contentView.frame.size.height-20)
  }
  
  public func configure(with viewModel: Category,label: Category){
    myImageView.image = UIImage(named: viewModel.category) ?? UIImage(named: "1")
    myImageView.tintColor = .systemTeal
    myLabel.text = viewModel.category
    myLabel.textColor = .systemPink
  }
  public func configure(image: String,label: String){
    myImageView.image = UIImage(named: image) ?? UIImage(named: "1")
    myImageView.tintColor = .systemTeal
    myLabel.text = image
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    myLabel.text = nil
    myImageView.image = nil
  }
}


