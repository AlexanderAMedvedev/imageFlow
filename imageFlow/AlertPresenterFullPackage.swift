//
//  AlertPresenter.swift
//  imageFlow
//
//  Created by Александр Медведев on 27.09.2023.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    func show()
}

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(alert: UIAlertController, completion: (() -> Void)?)
    func createAlertModel() -> AlertViewModel
}

struct AlertViewModel {
    let title: String
    let message: String
    let buttonText: String
    // The block to execute after the presentation of alert finishes (see `present(_:animated:completion:) for UIViewController`)
    var handler: ((UIAlertAction) -> Void)?
}

class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?
    var alertSome: AlertViewModel
    
    init(
        delegate: AlertPresenterDelegate,
        alertSome: AlertViewModel
    ) {
        self.delegate = delegate
        self.alertSome = alertSome
    }
    
    func show() {
        //1) Создание для алерта
        //  объектов
        let alert = UIAlertController(
            title: alertSome.title,     // заголовок всплывающего окна
            message: alertSome.message, // текст во всплывающем окне
            preferredStyle: .alert      // preferredStyle может быть .alert или .actionSheet
        )
        //  кнопки с действием
        let action = UIAlertAction(
                                   title: alertSome.buttonText,
                                   style: .default,
                                   handler: alertSome.handler
                                   )
        //  присутствия кнопки
        alert.addAction(action)
        //2) Передача подготовленного алерта делегату
        delegate?.showAlert(alert: alert, completion: nil)
    }
}
