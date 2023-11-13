//
//  ImagesListPresenter.swift
//  imageFlow
//
//  Created by Александр Медведев on 07.11.2023.
//

import Foundation
import UIKit
public protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    //func fetchPhotosNextPageNextDownload()
    func countRowsInTable() -> Int
    func downloadNextPage(if indexPathRow: Int)
    func prepareIndexPaths() -> [IndexPath]
    func aspectRatio(for indexPath: IndexPath) -> Double
    func writeLike(for cell: ImagesListCell, under index: IndexPath)
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, moment: String)
    func largeImageURL(indexPath: IndexPath) -> String
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    private let imagesListService = ImagesListService.shared
    
    weak var view: ImagesListViewControllerProtocol?
    
    private func fetchPhotosNextPageNextDownload() {
        imagesListService.fetchPhotosNextPage(){ [weak self] result in
            DispatchQueue.main.async  {
                guard let self = self else { return }
                switch result {
                case .success:
                    break
                case .failure:
                    var alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось загрузить фото в json-файле", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ок", style: .default)
                    alert.addAction(action)
                    self.view?.presentAlert(alert)
                }
            }
        }
    }
    
    func downloadNextPage(if indexPathRow: Int) {
        if  indexPathRow + 1 == imagesListService.photos.count {
            //print("HINT Time to download the next page of photos.")
            fetchPhotosNextPageNextDownload()
        }
    }
    
    func prepareIndexPaths() -> [IndexPath] {
        guard let lastLoadedPage = imagesListService.lastLoadedPage else {
            fatalError("lastLoadedPage is nil!")
            }
        let imagesPerPage = imagesListService.imagesPerPage
        let indexPhotoNextPage = (lastLoadedPage-1)*imagesPerPage
        var indexPaths: [IndexPath] = []
        for i in 0...(imagesPerPage - 1) {
            indexPaths.append(IndexPath(row: indexPhotoNextPage + i,section: 0))
        }
        return indexPaths
    }
    
    func aspectRatio(for indexPath: IndexPath) -> Double {
        imagesListService.photos[indexPath.row].size.height/imagesListService.photos[indexPath.row].size.width
    }
    
    func writeLike(for cell: ImagesListCell, under index: IndexPath) {
        let photoId = imagesListService.photos[index.row].id
        let photoLikedByUser = imagesListService.photos[index.row].likedByUser
        
        imagesListService.writeLike(indexPhoto: index.row, photoId: photoId, isLikeToBeSet: !photoLikedByUser) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.configCell(for: cell, with: index, moment: "changeLike")
                    UIBlockingProgressHUD.dismiss()
                case .failure:
                    UIBlockingProgressHUD.dismiss()
                    var alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось изменить состояние лайка на сервере", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ок", style: .default)
                    alert.addAction(action)
                    self.view?.presentAlert(alert)
                }
            }
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, moment: String) {

        let photoData = imagesListService.photos[indexPath.row]
        if photoData.likedByUser == false {
            view?.setImageForLike("noLike", for: cell)
        } else if photoData.likedByUser == true {
            view?.setImageForLike("Like", for: cell)
        }
        
        if moment == "initialConfig" {
            let url = URL(string: imagesListService.photos[indexPath.row].thumbImageURL)
            let placeHolder = UIImage(named: "scribble_variable")
            cell.imageCell.kf.indicatorType = .activity
            cell.imageCell.kf.setImage(with: url, placeholder: placeHolder)
            
            guard let createdAt = imagesListService.photos[indexPath.row].createdAt else { return }
            view?.setDateForPhoto(createdAt, for: cell)
            view?.setDelegateForCell(cell)
        }
    }
    
    func countRowsInTable() -> Int {
        imagesListService.photos.count
    }
    
    func largeImageURL(indexPath: IndexPath) -> String {
        imagesListService.photos[indexPath.row].largeImageURL
    }
}
