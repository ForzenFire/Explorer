////
////  HomeHeaderView.swift
////  Explorer
////
////  Created by Kavindu Dilshan on 2025-04-08.
////
//import UIKit
//
//class HomeHeaderView: UIView {
//    private let profileImageView: UIImage = {
//        let imageView = UIImageView(image: UIImage(named: "profile_placeholder"))
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = 20
//        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageViewCannot
//    }()
//    
//    private let nameLabel: UILabel = {
//        let lable = UILabel()
//        label.text = "Dilshan"
//        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        let fullText = "Explore the Beautiful Island!"
//        let attributed = NSMutableAttributedString(string: fullText)
//        
//        attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 22, weight: .regular), range: NSRange(location: 0, length: 11))
//        attributed.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 24), range: NSRange(location: 11, length: 10))
//        attributed.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: NSRange(location: 22, length: 7))
//                
//        label.attributedText = attributed
//        label.numberOfLines = 2
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//            super.init(frame: frame)
//            setupView()
//        }
//
//        required init?(coder: NSCoder) {
//            super.init(coder: coder)
//            setupView()
//        }
//
//        private func setupView() {
//            addSubview(profileImageView)
//            addSubview(nameLabel)
//            addSubview(titleLabel)
//
//            NSLayoutConstraint.activate([
//                profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
//                profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//                profileImageView.widthAnchor.constraint(equalToConstant: 40),
//                profileImageView.heightAnchor.constraint(equalToConstant: 40),
//
//                nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
//                nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
//
//                titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
//                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//            ])
//        }
//}
