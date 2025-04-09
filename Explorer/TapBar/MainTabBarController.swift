//
//  MainTabBarController.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-09.
//
import UIKit

class MainTabBarController: UITabBarController {
    
    let customAddButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupAddButton()
    }
    
    private func setupViewControllers() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag:0)

        let mapVC = UINavigationController(rootViewController: MapViewController())
        mapVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 1)

        let dummyVC = UIViewController() // Will trigger add post
        dummyVC.tabBarItem = UITabBarItem(title: nil, image: nil, tag: 2)

        let messagesVC = UINavigationController(rootViewController: ChatViewController())
        messagesVC.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "message"), tag: 3)

        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 4)

        viewControllers = [homeVC, mapVC, dummyVC, messagesVC, profileVC]
    }

    private func setupAddButton() {
        customAddButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        customAddButton.tintColor = .systemBlue
        customAddButton.backgroundColor = .white
        customAddButton.layer.cornerRadius = 32
        customAddButton.layer.shadowColor = UIColor.black.cgColor
        customAddButton.layer.shadowOpacity = 0.3
        customAddButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        customAddButton.layer.shadowRadius = 5
        customAddButton.translatesAutoresizingMaskIntoConstraints = false
        customAddButton.addTarget(self, action: #selector(addPostTapped), for: .touchUpInside)

        view.addSubview(customAddButton)

        NSLayoutConstraint.activate([
            customAddButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            customAddButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor),
            customAddButton.widthAnchor.constraint(equalToConstant: 64),
            customAddButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    @objc private func addPostTapped() {
        let addPostVC = AddReminderController()
        addPostVC.modalPresentationStyle = .fullScreen
        present(addPostVC, animated: true, completion: nil)
    }
}
