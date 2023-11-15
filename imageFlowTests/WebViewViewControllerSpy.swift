//
//  WebViewViewControllerSpy.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 05.11.2023.
//

import Foundation
import imageFlow

final class WebViewViewControllerSpy:  WebViewViewControllerProtocol {
    var presenter: imageFlow.WebViewPresenterProtocol?
    var loadDidCall = false
    
    func load(request: URLRequest) {
        loadDidCall = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
    
    
}
