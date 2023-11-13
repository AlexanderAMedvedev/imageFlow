//
//  ImagesListTests.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 08.11.2023.
//
@testable import imageFlow
import XCTest

final class ImagesListTests: XCTestCase {
    func testDidCallCountRowsInTable() {
        //arrange
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        var imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController
        guard var imagesListViewController else { fatalError("Can not unwrap imagesListViewController")}
        
        let presenter = ImagesListPresenterSpy()
        
        imagesListViewController.presenter = presenter
        presenter.view = imagesListViewController
        _ = imagesListViewController.view
        
        guard let table = imagesListViewController.tableView else {fatalError("Did not unwrap the table")}
        let section = 0
        //act
        
        let numberOfRowsInSection = imagesListViewController.tableView(table, numberOfRowsInSection: section)
        //assert
        XCTAssertTrue(presenter.didCallCountRowsInTable)
        XCTAssertEqual(numberOfRowsInSection, 1)
    }
    
    func testDidCallAspectRatio() {
        //arrange
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        var imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController
        guard var imagesListViewController else { fatalError("Can not unwrap imagesListViewController")}
        
        let presenter = ImagesListPresenterSpy()
        
        imagesListViewController.presenter = presenter
        presenter.view = imagesListViewController
        _ = imagesListViewController.view
        
        guard let table = imagesListViewController.tableView else {fatalError("Did not unwrap the table")}
        //let section = 0
        //act
        _ = imagesListViewController.tableView(table, heightForRowAt: IndexPath(row: 0, section: 0))
        //assert
        XCTAssertTrue(presenter.didCallAspectRatio)
    }
    
    func testImagesListDidCallConfigCell() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        var imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as? ImagesListViewController
        guard var imagesListViewController else { fatalError("Can not unwrap imagesListViewController")}
        
        var presenter = ImagesListPresenterSpy()
        imagesListViewController.presenter = presenter
        presenter.view = imagesListViewController
        _ = imagesListViewController.view
        
        guard let table = imagesListViewController.tableView else {fatalError("Did not unwrap the table")}
        //act
        _ = imagesListViewController.tableView(table, cellForRowAt: IndexPath(row: 0, section: 0))
        //assert
        XCTAssertTrue(presenter.didCallConfigCell)
    }
}
