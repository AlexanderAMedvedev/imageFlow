//
//  ProfileViewTests.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 06.11.2023.
//
@testable import imageFlow
import XCTest

final class ProfileViewTests: XCTestCase {
    func testProfileViewControllerDidCallUpdateAvatar() {
        var presenter = ProfileViewPresenterSpy()
        var viewController = ProfileViewController()
        presenter.view = viewController
        viewController.presenter = presenter
        _ = viewController.view
        XCTAssertTrue(presenter.didCallUpdateAvatar)
    }
    
    func testProfileViewControllerDidCallMakeAlert() {
        var viewController = ProfileViewController()
        var presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        viewController.didTapExitButton()
        XCTAssertTrue(presenter.didCallMakeAlert)
    }
    
    func testProfileViewPresenterDidCallPresentAlert() {
        var viewController = ProfileViewControllerSpy()
        var presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.makeAlert()
        XCTAssertTrue(viewController.didCallPresentAlert)
    }
    
}
