//
//  imageFlowUITests.swift
//  imageFlowUITests
//
//  Created by Александр Медведев on 08.11.2023.
//

import XCTest

final class imageFlowUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testAuth() throws {
        // тестируем сценарий авторизации
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("YOUR_PASSWORD")
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("YOUR_E-MAIL")
        
        app.toolbars["Toolbar"].buttons["Done"].tap()
        webView.buttons["Login"].tap()
        
        let table = app.tables
        let cell = table.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        //print(app.debugDescription)
    }
        
    func testFeed() throws {
            // тестируем сценарий ленты
        sleep(6)
        let table = app.tables["TableWithImages"]
        XCTAssertTrue(table.waitForExistence(timeout: 4))
        
        table.swipeUp()
        table.swipeDown()
        
        let cell = table.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 4))
        cell.buttons["LikeSymbol"].tap()
        sleep(5)
        cell.buttons["LikeSymbol"].tap()
        sleep(3)
        cell.tap()
        sleep(3)
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 2))
        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        app.buttons["BackFromSingleImage"].tap()
    }
        
    func testProfile() throws {
        // тестируем сценарий профиля
            // Подождать, пока открывается и загружается экран ленты
        sleep(6)
        let table = app.tables["TableWithImages"]
        XCTAssertTrue(table.waitForExistence(timeout: 4))
            // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(2)
            // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["YOUR_NAME__YOUR_FAMILY_NAME"].exists)
        XCTAssertTrue(app.staticTexts["@YOUR_USER_NAME"].exists)
            // Нажать кнопку логаута
        app.buttons["ipad.and.arrow"].tap()
        app.alerts["Пока, пока"].scrollViews.otherElements.buttons["Да"].tap()
            // Проверить, что открылся экран авторизации
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
    }
}
