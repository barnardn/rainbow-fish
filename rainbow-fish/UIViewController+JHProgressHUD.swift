//
//  UIViewController+JHProgressHUD.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showHUD(#header: String?, footer: String?) {
        dispatch_async(dispatch_get_main_queue(), {[unowned self] () -> Void in
            if let (header, footer) = (header, footer) as (String?,String?)? {
                JHProgressHUD.sharedHUD.showInView(self.view, withHeader: header, andFooter: footer)
            } else {
                JHProgressHUD.sharedHUD.showInView(self.view)
            }
        })
    }
    
    func showHUD() {
        return showHUD(header: nil, footer: nil)
    }
    
    func hideHUD() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            JHProgressHUD.sharedHUD.hide()
        })
    }
    
}