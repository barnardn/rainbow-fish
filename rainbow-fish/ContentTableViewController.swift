//
//  ContentTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class ContentTableViewController: UITableViewController {
    
    private var kvoContext = 0;
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    deinit {
        AppController.appController.removeObserver(self, forKeyPath: "bannerAdIsVisible", context: &kvoContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.All.exclusiveOr(UIRectEdge.Top).exclusiveOr(UIRectEdge.Bottom)
        self.view.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.separatorColor = AppearanceManager.appearanceManager.strokeColor
        AppController.appController.addObserver(self, forKeyPath: "bannerAdIsVisible", options: [.New, .Initial], context: &kvoContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != &kvoContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        if keyPath == "bannerAdIsVisible" {
            var bannerOffset = 50.0
            if  let isVisible = change?[NSKeyValueChangeNewKey] as? NSNumber where isVisible.boolValue == false {
                bannerOffset = 0.0
            }
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(bannerOffset), right: 0)
        }
    }
    
    
}
