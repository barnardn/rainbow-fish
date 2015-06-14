//
//  UIViewController+JHProgressHUD.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showHUD(#message: String?) {
        
        dispatch_async(dispatch_get_main_queue(), {[unowned self] () -> Void in
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
    
}