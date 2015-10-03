//
//  UIViewController+JHProgressHUD.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showHUD(message message: String?) {
        
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            SwiftFullScreenLoader.show(title: message)
        })
    }
    
    func showHUD() {
        self.showHUD(message: nil)
    }
    
    func hideHUD() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            SwiftFullScreenLoader.hide()
        })
    }
    
    func showSmallHUD(message message: String?) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            SwiftLoader.show(title: message, animated: true)
        })
    }
    
    func hideSmallHUD() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            SwiftLoader.hide()
        })
    }
    
}