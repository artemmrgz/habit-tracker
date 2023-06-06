//
//  MainViewController.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 31/05/2023.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTabBar()
    }

    private func setupViews() {
        let homeVC = HomeViewController()
        let settingsVC = SettingsViewController()

        homeVC.setTabBarImage(imageName: "house", title: "Home", tag: 0)
        settingsVC.setTabBarImage(imageName: "gearshape", title: "Settings", tag: 1)

        let homeNC = UINavigationController(rootViewController: homeVC)
        let settingsNC = UINavigationController(rootViewController: settingsVC)

        viewControllers = [homeNC, settingsNC]
    }

    private func setupTabBar() {
        tabBar.tintColor = .systemRed
        tabBar.unselectedItemTintColor = .systemGray
    }
}

class SettingsViewController: UIViewController {

}
