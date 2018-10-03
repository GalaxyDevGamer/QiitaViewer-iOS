//
//  AlertHelper.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/10/02.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import Foundation
import UIKit

class AlertHelper {
    
    static let make = AlertHelper()
    
    func errorAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
    
    func dialog(title: String, message: String) -> UIAlertController {
        let dialog = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        dialog.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        return dialog
    }
}
