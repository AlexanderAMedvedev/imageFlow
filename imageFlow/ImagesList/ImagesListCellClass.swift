//
//  ImagesListCellClass.swift
//  imageFlow
//
//  Created by Александр Медведев on 06.06.2023.
//

import Foundation
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var dateCell: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCell.kf.cancelDownloadTask()
       // print("HINT The cell is prepared for reuse")
    }
}
