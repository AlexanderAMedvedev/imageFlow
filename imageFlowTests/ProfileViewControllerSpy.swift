//
//  ProfileViewControllerSpy.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 06.11.2023.
//

import Foundation
import imageFlow
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: imageFlow.ProfileViewPresenterProtocol?
    var didCallPresentAlert = false
    
    func addPersonalPhotoView(_ url: URL) {
        
    }
    
    func presentAlert(_ alert: UIAlertController) {
        didCallPresentAlert = true
    }
    
    
}
