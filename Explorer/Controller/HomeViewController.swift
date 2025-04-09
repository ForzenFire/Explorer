//
//  HomeViewController.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-09.
//
import UIKit

class HomeViewController: UIViewController {

    private let headerView = HomeHeaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        navigationController?.setNavigationBarHidden(true, animated: false)

        setupHeader()
    }

    private func setupHeader() {
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 130)
        ])
    }
}
