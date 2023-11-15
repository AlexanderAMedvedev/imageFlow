//
//  WebViewPresenterSpy.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 05.11.2023.
//

import Foundation
import imageFlow

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
    
    
}
