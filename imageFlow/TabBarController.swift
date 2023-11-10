//
//  TabBarController.swift
//  imageFlow
//
//  Created by Александр Медведев on 24.09.2023.
//

import Foundation
import UIKit
 
final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        var imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController
        guard var imagesListViewController else { fatalError("Can not unwrap imagesListViewController")}
        var imagesListPresenter = ImagesListPresenter()
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController
        
        
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenter()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        profileViewController.tabBarItem = UITabBarItem(
                    title: nil,
                    image: UIImage(named: "tab_profile_active"),
                    selectedImage: nil
                )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
