//
//  ProfileViewPresenterSpy.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 06.11.2023.
//

import Foundation
import imageFlow

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    func makeAlert() {
    }
    
    weak var view: imageFlow.ProfileViewControllerProtocol?
    
    var didCallUpdateAvatar = false
    
    func updateAvatar() {
        didCallUpdateAvatar = true
    }
    
    func clean() {
        
    }
    
    func tokenSetNil() {
        
    }
    
    func createNextWindow() {
        
    }
    
    
}
