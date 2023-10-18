//
//  ViewController.swift
//  imageFlow
//
//  Created by Александр Медведев on 31.05.2023.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
//Q: 1) `tableView.register(ImagesListCell.self,...`
    
    @IBOutlet private var tableView: UITableView!
    private let imagesListService = ImagesListService.shared

    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        // var contentInset: UIEdgeInsets { get set }
        // The custom distance that the content view is inset(вставка) from the safe area or scroll view edges.
        NotificationCenter.default.addObserver(
             forName: ImagesListService.didChangeNotification,
                 object: nil,
                 queue: .main
             ) {  [weak self] _ in
                 guard let self = self else { return }
                 self.updateTableViewAnimated()
             }
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, moment: String) {

        let photoData = imagesListService.photos[indexPath.row]
        if photoData.likedByUser == false {
            cell.likeButton.imageView?.image = UIImage(named: "noLike")
        } else if photoData.likedByUser == true {
            cell.likeButton.imageView?.image = UIImage(named: "Like")
        }
        
        if moment == "initialConfig" {
            let url = URL(string: imagesListService.photos[indexPath.row].thumbImageURL)
            let placeHolder = UIImage(named: "scribble_variable")
            cell.imageCell.kf.indicatorType = .activity
            cell.imageCell.kf.setImage(with: url, placeholder: placeHolder)
            
            guard let createdAt = imagesListService.photos[indexPath.row].createdAt else { return }
            cell.dateCell.text = dateFormatter.string(from: createdAt) 
            
            cell.delegate = self
        }
    }
}

extension ImagesListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == ShowSingleImageSegueIdentifier {
                let viewController = segue.destination as! SingleImageViewController
                let indexPath = sender as! IndexPath
                let urlFullPhoto = imagesListService.photos[indexPath.row].largeImageURL
                viewController.imageUrl = urlFullPhoto
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    
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
                        self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func updateTableViewAnimated() {
        guard let lastLoadedPage = imagesListService.lastLoadedPage else {
            print("lastLoadedPage is nil!")
            return }
        let imagesPerPage = imagesListService.imagesPerPage
        let indexPhotoNextPage = (lastLoadedPage-1)*imagesPerPage
        var indexPaths: [IndexPath] = []
        for i in 0...(imagesPerPage - 1) {
            indexPaths.append(IndexPath(row: indexPhotoNextPage + i,section: 0))
        }
        
        tableView.performBatchUpdates {
            self.tableView.insertRows(at: indexPaths,with: .automatic)
        } completion: { _ in
            //print("HINT the table is longer")
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("HINT numberOfRowsInSection = \(imagesListService.photos.count)")
        return imagesListService.photos.count //photosName.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        // func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell
        // - Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
        guard let imageListCell = cell as? ImagesListCell else {
            print("Cell of the needed type was not created")
            return UITableViewCell()
        }
                
        configCell(for: imageListCell, with: indexPath, moment: "initialConfig")
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let widthImageView = tableView.contentSize.width-16-16
        let aspectRatio = imagesListService.photos[indexPath.row].size.height/imagesListService.photos[indexPath.row].size.width
        let heightCell = 4+aspectRatio*widthImageView+4
        return heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            //print("HINT Time to download the next page of photos.")
            fetchPhotosNextPageNextDownload()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let index = tableView.indexPath(for: cell) else {
            print("Can not get the indexPath of the tapped like")
        return
        }
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
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
}
