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

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func addPersonalPhotoView(_ url: URL)
    func presentAlert(_ alert: UIAlertController)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?

    static var exitImage = UIImage(named: "ipad.and.arrow.forward")!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return .lightContent
    }
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        let profileService = ProfileService.shared
        addExitButton()
        addNameFamilyNameLabel(profileService.profile?.name ?? "Was not downloaded")
        addTaggedUserName(profileService.profile?.loginName ?? "Was not downloaded")
        addUserMessage(profileService.profile?.bio ?? "Was not downloaded")
            
        profileImageServiceObserver = NotificationCenter.default.addObserver(
                forName: ProfileImageService.didChangeNotification, // 3
                object: nil,                                        // 4
                queue: .main                                        // 5
            ) { [weak self] _ in
                guard let self = self else { return }
                self.presenter?.updateAvatar()                                 // 6
            }
        presenter?.updateAvatar()
    }
        
     func addPersonalPhotoView(_ url: URL) {
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
        return
    }
    
     private func addExitButton()  {
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
        return
    }
    
    @objc private func didTapExitButton() {
        presenter?.makeAlert()
    }
    
    func presentAlert(_ alert: UIAlertController) {
            present(alert, animated: true)
    }
    
     private func addNameFamilyNameLabel(_ fullName: String)  {
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
        return
    }
    
     private func addTaggedUserName(_ taggedUserNameString: String)  {
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
        return
    }
    
     private func addUserMessage(_ userBio: String)  {
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
        return
    }
}
