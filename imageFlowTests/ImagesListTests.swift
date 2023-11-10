//
//  ImagesListTests.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 08.11.2023.
//
@testable import imageFlow
import XCTest

final class ImagesListTests: XCTestCase {
   /* func testOne() {
        //arrange
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        var imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController
        guard var imagesListViewController else { fatalError("Can not unwrap imagesListViewController")}
        
        let presenter = ImagesListPresenterSpy()
        
        imagesListViewController.presenter = presenter
        presenter.view = imagesListViewController
        
        //guard let table = imagesListViewController.tableView else {fatalError("Did not unwrap the table")}
        let section = 0
        //act
        
        let numberOfRowsInSection = imagesListViewController.tableView(imagesListViewController.tableView, numberOfRowsInSection: section)
        //assert
        XCTAssertTrue(presenter.DidCallCountRowsInTable)
        XCTAssertEqual(numberOfRowsInSection, 1)
    }*/
}
