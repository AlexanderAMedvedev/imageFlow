//
//  ProfileViewController.swift
//  imageFlow
//
//  Created by Александр Медведев on 12.06.2023.
//

import Foundation
import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    
    private let oauth2TokenStorage = OAuth2TokenStorage()

    static var exitImage = UIImage(named: "ipad.and.arrow.forward")!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return .lightContent
    }
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        let profileService = ProfileService.shared

        addExitButton()
        addNameFamilyNameLabel(profileService.profile!.name)
        addTaggedUserName(profileService.profile!.loginName)
        addUserMessage(profileService.profile!.bio)
            
        profileImageServiceObserver = NotificationCenter.default.addObserver(
                forName: ProfileImageService.didChangeNotification, // 3
                object: nil,                                        // 4
                queue: .main                                        // 5
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()                                 // 6
            }
        updateAvatar()
    }
        
    private func updateAvatar() {                                   // 8
            guard
                let profileImageURL = ProfileImageService.shared.profileSmallImageURL,
                let url = URL(string: profileImageURL)
            else { return }
            // TODO [Sprint 11] Обновить аватар, используя Kingfisher
        addPersonalPhotoView(url)
        }
    @discardableResult private func addPersonalPhotoView(_ url: URL) -> UIImageView {
        let personalPhotoView = UIImageView(image: UIImage())
        personalPhotoView.kf.indicatorType = .activity
        //personalPhotoView.kf.setImage(with: url)
        //personalPhotoView.layer.cornerRadius = 20
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        personalPhotoView.kf.setImage(with: url, options: [.processor(processor), .cacheSerializer(FormatIndicatedCacheSerializer.png)]) //in order to save image with alpha-channel
        
        personalPhotoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(personalPhotoView)
        NSLayoutConstraint.activate([
            personalPhotoView.heightAnchor.constraint(equalToConstant: 70),
            personalPhotoView.widthAnchor.constraint(equalToConstant: 70),
            personalPhotoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            personalPhotoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        return personalPhotoView
    }
    
    @discardableResult private func addExitButton() -> UIButton {
        let exitButton = UIButton.systemButton(
            with: ProfileViewController.exitImage,
            target: self,
            action: #selector(self.didTapExitButton)
        )
        exitButton.tintColor = .ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        NSLayoutConstraint.activate([
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        return exitButton
    }
    
    @objc private func didTapExitButton() {
        
            var alert = UIAlertController(title: "Пока, пока", message: "Точно хотите выйти?", preferredStyle: .alert)
            
            let actionNo = UIAlertAction(title: "Нет", style: .default)
            alert.addAction(actionNo)
            
            let actionYes = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.oauth2TokenStorage.token = nil
                self.clean()
                guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
                let viewController = SplashViewController()
                window.rootViewController = viewController
            }
            alert.addAction(actionYes)
            present(alert, animated: true)
    }
    
    
    private func clean() {
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
    
    @discardableResult private func addNameFamilyNameLabel(_ fullName: String) -> UILabel {
        let nameFamilyNameLabel = UILabel()
        nameFamilyNameLabel.text = fullName //"Екатерина Новикова"
        nameFamilyNameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameFamilyNameLabel.textColor = .ypWhite
        nameFamilyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameFamilyNameLabel)
        NSLayoutConstraint.activate([
            nameFamilyNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 102),
            nameFamilyNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        return nameFamilyNameLabel
    }
    
    @discardableResult private func addTaggedUserName(_ taggedUserNameString: String) -> UILabel {
        let taggedUserName = UILabel()
        taggedUserName.text = taggedUserNameString // "@ekaterina_nov"
        taggedUserName.font = UIFont.systemFont(ofSize: 13)
        taggedUserName.textColor = .ypWhite
        taggedUserName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taggedUserName)
        NSLayoutConstraint.activate([
            taggedUserName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 136),
            taggedUserName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)            
        ])
        return taggedUserName
    }
    
    @discardableResult private func addUserMessage(_ userBio: String) -> UILabel {
        let userMessage = UILabel()
        userMessage.textColor = .ypWhite
        userMessage.font = UIFont.systemFont(ofSize: 13)
        userMessage.text = userBio //"Hello, world!"
        
        userMessage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userMessage)
        NSLayoutConstraint.activate([
            userMessage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 162),
            userMessage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        return userMessage
    }
}
