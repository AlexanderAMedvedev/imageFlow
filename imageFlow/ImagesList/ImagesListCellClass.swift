//
//  ImagesListCellClass.swift
//  imageFlow
//
//  Created by Александр Медведев on 06.06.2023.
//

import Foundation
import UIKit
import Kingfisher
import ProgressHUD

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var dateCell: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction func didTapLikeButton(_ sender: UIButton) {
        //print("didTapLikeButton")
        UIBlockingProgressHUD.show()
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCell.kf.cancelDownloadTask()
       // print("HINT The cell is prepared for reuse")
    }
    
}
