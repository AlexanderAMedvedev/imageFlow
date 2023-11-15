//
//  ProfileViewPresenter.swift
//  imageFlow
//
//  Created by Александр Медведев on 06.11.2023.
//

import Foundation
import WebKit

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
   func updateAvatar()
   func clean()
   func tokenSetNil()
   func createNextWindow()
   func makeAlert()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.profileSmallImageURL,
            let url = URL(string: profileImageURL)
        else { return }
        // Обновить аватар, используя Kingfisher
        view?.addPersonalPhotoView(url)
    }
    
     func clean() {
        // Очищаем все куки из хранилища.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища.
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища.
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
       // print("HINT_pVC: browser is cleaned")
    }
    
    func tokenSetNil() {
        oauth2TokenStorage.token = nil
    }
    
    func createNextWindow() {
        guard let window = UIApplication.shared.windows.first else { assertionFailure("Invalid Configuration")
            return
        }
        let viewController = SplashViewController()
        window.rootViewController = viewController
    }
    
    func makeAlert() {
        let alert = UIAlertController(title: "Пока, пока", message: "Точно хотите выйти?", preferredStyle: .alert)
        
        let actionNo = UIAlertAction(title: "Нет", style: .default)
        alert.addAction(actionNo)
        
        let actionYes = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.tokenSetNil()
            self.clean()
            self.createNextWindow()
        }
        alert.addAction(actionYes)
        view?.presentAlert(alert)
    }
}
