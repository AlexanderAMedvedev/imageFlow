//
//  imageFlowTests.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 05.11.2023.
//
@testable import imageFlow
import XCTest

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given-arrange
        //create instance of WebViewViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //act
        _ = viewController.view
        //assert
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        //arrange
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        //act
        presenter.viewDidLoad()
        //assert
        XCTAssertTrue(viewController.loadDidCall)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //arrange
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let value: Float = 0.5
        //act
        let shouldHide = presenter.shouldHideProgress(for: value)
        //assert
        XCTAssertFalse(shouldHide)
    }
    
    func testProgressHiddenWhenOne() {
        //arrange
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progressValue: Float = 1
        //act
        let shouldHide = presenter.shouldHideProgress(for: progressValue)
        //assert
        XCTAssertTrue(shouldHide)
    }
    
    func testAuthHelperAuthURL() {
        //arrange
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper()
        //act
        let url = authHelper.authURL()
        let urlString = url.absoluteString
        //assert
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    func testCodeFromURL() {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        
        let authHelper = AuthHelper()
        
        let code = authHelper.code(from: url)
        //assert
        XCTAssertEqual(code, "test code")
    }
}
