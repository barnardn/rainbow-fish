//
//  RootViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init() {
        super.init()
        viewControllers = [
                InventoryNavigationController(),
                PencilViewController(style: .Plain),
                SettingsTableViewController(style: .Grouped)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor;
        
#if SEED_CLOUD
        self.makeRain()
#endif
        
        
        
        
    }
    
    

    
    //MARK: HUD methods
    
    func showHUD(#header: String?, footer: String?) {
        dispatch_async(dispatch_get_main_queue(), {[unowned self] () -> Void in
            if let (header, footer) = (header, footer) as (String?,String?)? {
                JHProgressHUD.sharedHUD.showInView(self.view, withHeader: header, andFooter: footer)
            } else {
                JHProgressHUD.sharedHUD.showInView(self.view)
            }
        })
    }
    
    func hideHUD() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            JHProgressHUD.sharedHUD.hide()
        })
    }
    
    //MARK: seed cloudkit
    //TODO: REMOVE BEFORE APP SUBMISSION!!
    
    private func makeRain() {
        showHUD(header: "Making Rain", footer: "Please Wait...")
        JHProgressHUD.sharedHUD.showInView(self.view, withHeader: "Making Rain", andFooter: "Please Wait...")
        var seeder = Seeder(seedFile: "prismacolor-pencils")
        seeder.seedPencilDatabase { [unowned self](countInserted, error) -> () in
            self.hideHUD()
            if error != nil {
                println("inserted: \(countInserted)")
            } else {
                println(error)
            }
        }
    }
    
    
}
