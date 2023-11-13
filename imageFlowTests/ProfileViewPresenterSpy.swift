//
//  ProfileViewPresenterSpy.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 06.11.2023.
//

import Foundation
import imageFlow

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {

    weak var view: imageFlow.ProfileViewControllerProtocol?
    
    var didCallUpdateAvatar = false
    var didCallMakeAlert = false
    
    func updateAvatar() {
        didCallUpdateAvatar = true
    }
    
    func makeAlert() {
        didCallMakeAlert = true
    }
    
    func clean() {
        
    }
    
    func tokenSetNil() {
        
    }
    
    func createNextWindow() {
        
    }
    
    
}
