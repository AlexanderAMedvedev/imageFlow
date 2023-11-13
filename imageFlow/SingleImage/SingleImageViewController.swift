//
//  SingleImageViewController.swift
//  imageFlow
//
//  Created by Александр Медведев on 13.06.2023.
//

import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet var imageView: UIImageView!
    
    //var image: UIImage! //for mock-data
    var imageUrl: String!
    
    @IBAction func didTapBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        //dismiss(распускать)
    }
    
    
    @IBAction func didTapShare(_ sender: UIButton) {
        let activityView =  UIActivityViewController(activityItems: [imageView.image as Any], applicationActivities: nil)
        // UIActivityViewController -
        present(activityView, animated: true, completion: nil)
        // `present` - Presents a view controller modally.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIBlockingProgressHUD.show()
        //imageUrl = "zero"
        let fullPhotoUrl = URL(string: imageUrl)
        imageView.kf.setImage(with: fullPhotoUrl) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                self.scrollView.minimumZoomScale = 0.7 //0.1
                self.scrollView.maximumZoomScale = 3   //1.25
                self.rescaleAndCenterImageInScrollView(image: imageView.image!)
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showAlert()
            }
        }
        //imageView.image = image //for mock-data
    }
    
    private func showAlert() {
        var alert = UIAlertController(title: "Что-то пошло не так(", message: "Попробовать ещё раз?", preferredStyle: .alert)
        
        let actionNo = UIAlertAction(title: "Не надо", style: .default)
        alert.addAction(actionNo)
        
        let actionRepeat = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewDidLoad()
        }
        alert.addAction(actionRepeat)
        
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        // 'constants'
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        // rescale to fully fit the screen
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size //for mock data
        //print("HINT_rescale \(imageSize)")
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        //variant by myself
        let scale = min(hScale, vScale)
        //variant by YandexPracticum
        //let theoreticalScale = max(hScale, vScale)
        //let scale = min(maxZoomScale, max(minZoomScale, theoreticalScale))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        // offset the content so the centers of content and scrollView coincide
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
}

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
}
