//
//  ShowAlertProtocol.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 7/7/21.
//

import UIKit

protocol ShowAlertProtocol {
    func showAlert(alertMessage : String)
}

extension ShowLoaderProtocol where Self: UIViewController {
    func showAlert(alertMessage : String) {
        let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Got it", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
