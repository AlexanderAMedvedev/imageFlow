//
//  ViewController.swift
//  imageFlow
//
//  Created by Александр Медведев on 31.05.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {
//Q: 1) `tableView.register(ImagesListCell.self,...`
//   2) tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    
    @IBOutlet private var tableView: UITableView!
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    // @frozen struct Array<Element> - An ordered, random-access (произвольный доступ) collection.
    // func map<T>(_ transform: (Self.Element) throws -> T) rethrows -> [T]
    // Returns an array containing the results of mapping the given closure over the sequence’s elements
    // (замыкание на элементах последовательности.)
    
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
        // Do any additional setup after loading the view.
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        // var contentInset: UIEdgeInsets { get set }
        // The custom distance that the content view is inset(вставка) from the safe area or scroll view edges.
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        if indexPath.row%2 == 1 {
            cell.likeButton.imageView?.image = UIImage(named: "Like")
        } else {
            cell.likeButton.imageView?.image = UIImage(named: "noLike")
        }
        
        let imageName = photosName[indexPath.row]
        if let image = UIImage(named: imageName) {
            cell.imageCell.image = image
        } else {
            return
        }
        
        cell.dateCell.text = dateFormatter.string(from: Date())
    }
}

extension ImagesListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == ShowSingleImageSegueIdentifier {
                let viewController = segue.destination as! SingleImageViewController
                let indexPath = sender as! IndexPath
                let image = UIImage(named: photosName[indexPath.row])
                //_ = viewController.view // CRASH FIXED !?
                viewController.image = image
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        // func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell
        // - Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
        guard let imageListCell = cell as? ImagesListCell else {
            print("Cell of the needed type was not created")
            return UITableViewCell()
        }
                
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = photosName[indexPath.row]
        if let image = UIImage(named: imageName) {
            let widthImageView = tableView.contentSize.width-16-16
            let aspectRatio = image.size.height/image.size.width
            let heightCell = 4+aspectRatio*widthImageView+4
            return heightCell
        } else {
            print("Can not make the image for determining the heightForRow.")
            return 34
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
}
