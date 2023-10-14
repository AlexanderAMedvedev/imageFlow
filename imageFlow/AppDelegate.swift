//
//  AppDelegate.swift
//  imageFlow
//
//  Created by Александр Медведев on 31.05.2023.
//
//
import UIKit
import ProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


// входная точка приложения
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       /* ProgressHUD.animationType = .systemActivityIndicator
        ProgressHUD.colorHUD = .black
        ProgressHUD.colorAnimation = .lightGray */ // I do not like this variant
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
       let sceneConfiguration = UISceneConfiguration(          // 1
                name: "Main",
                sessionRole: connectingSceneSession.role
            )
            sceneConfiguration.delegateClass = SceneDelegate.self   // 2
            return sceneConfiguration 
       /* return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)*/
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

