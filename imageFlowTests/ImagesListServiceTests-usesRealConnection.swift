//
//  imageFlowTests.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 05.10.2023.
//
@testable import imageFlow
import XCTest

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
        let service = ImagesListService()
        let expectation = self.expectation(description: "Wait for Notification")
        //.expectation - Creates a new expectation(ожидание) with an associated description.
        // Use this method to create XCTestExpectation instances that can be fulfilled when asynchronous tasks in your tests complete.
        
        NotificationCenter.default.addObserver(
                                // .addObserver - Adds an entry(ввод) to the notification center to receive notifications that passed to the provided block.
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
                        //.fulfill() - Marks the expectation as having been met.
            }
        
        service.fetchPhotosNextPage()
        
        wait(for: [expectation], timeout: 10)
        //wait - Waits for the test to fulfill a set of expectations within a specified time.
        XCTAssertEqual(service.photos.count, 10)
    }
}
