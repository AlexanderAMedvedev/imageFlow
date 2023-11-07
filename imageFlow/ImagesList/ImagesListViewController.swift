//
//  ViewController.swift
//  imageFlow
//
//  Created by Александр Медведев on 31.05.2023.
//

import UIKit
import Kingfisher
public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get  set }
    func presentAlert(_ alert: UIAlertController)
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, moment: String)
}
final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
//Q: 1) `tableView.register(ImagesListCell.self,...`
    var presenter: ImagesListPresenterProtocol?

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
    
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
    
    private func updateTableViewAnimated() {
        tableView.performBatchUpdates {
            self.tableView.insertRows(at: presenter!.prepareIndexPaths(),with: .automatic)
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
        let heightCell = 4+presenter!.aspectRatio(for: indexPath)*widthImageView+4
        return heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.downloadNextPage(if: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let index = tableView.indexPath(for: cell) else {
            print("Can not get the indexPath of the tapped like")
        return
        }
        presenter?.writeLike(for: cell, under: index)
    }
    
}
