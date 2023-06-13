//
//  SingleImageViewController.swift
//  imageFlow
//
//  Created by Александр Медведев on 13.06.2023.
//

import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage!
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
}
