//
//  UIViewController+JHProgressHUD.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showHUD(message: String?) {
        
        DispatchQueue.main.async(execute: {() -> Void in
            SwiftFullScreenLoader.show(title: message)
        })
    }
    
    func showHUD() {
        self.showHUD(message: nil)
    }
    
    func hideHUD() {
        DispatchQueue.main.async(execute: { () -> Void in
            SwiftFullScreenLoader.hide()
        })
    }
    
    func showSmallHUD(message: String?) {
        DispatchQueue.main.async(execute: { () -> Void in
            SwiftLoader.show(title: message, animated: true)
        })
    }
    
    func hideSmallHUD() {
        DispatchQueue.main.async(execute: { () -> Void in
            SwiftLoader.hide()
        })
    }
    
    func presentErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment:"error alert dismiss button"), style: .cancel, handler: nil))
        let viewController = self.presentedViewController ?? self
        if viewController.isKind(of: UIAlertController.self) {
            return
        }
        viewController.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = AppearanceManager.appearanceManager.brandColor
    }
    
}
