//
//  ProfileViewController.swift
//  imageFlow
//
//  Created by Александр Медведев on 12.06.2023.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet private weak var viewPersonalPhoto: UIImageView!
    
    @IBOutlet private weak var PersonalName: UILabel!
    
    @IBOutlet weak var personalIdentifier: UILabel!
    
    @IBOutlet weak var personalMessage: UILabel!
    @IBAction func exitClicked(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
}
