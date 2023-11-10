//
//  ImagesListPresenterSpy.swift
//  imageFlowTests
//
//  Created by Александр Медведев on 09.11.2023.
//

import Foundation
import imageFlow

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: imageFlow.ImagesListViewControllerProtocol?
    var DidCallCountRowsInTable = false
    func countRowsInTable() -> Int {
        DidCallCountRowsInTable = true
        return 1
    }
    
    func downloadNextPage(if indexPathRow: Int) {
        
    }
    
    func prepareIndexPaths() -> [IndexPath] {
        return [IndexPath(row: 0, section: 0)]
    }
    
    func aspectRatio(for indexPath: IndexPath) -> Double {
        1.0
    }
    
    func writeLike(for cell: imageFlow.ImagesListCell, under index: IndexPath) {
        
    }
    
    func configCell(for cell: imageFlow.ImagesListCell, with indexPath: IndexPath, moment: String) {
        
    }
    
    
}
