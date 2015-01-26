//
//  AppearanceManager.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 1/25/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import Foundation
import UIKIt

class AppearanceManager {
    
    class var appearanceManager: AppearanceManager {
        struct Singleton {
            static let instance = AppearanceManager()
        }
        return Singleton.instance
    }
    
    lazy var brandColor: UIColor = {
        return UIColor(red: 11.0/256.0, green: 163.0/256.0, blue: 244.0/256.0, alpha: 1.0)
    }()
    
    lazy var brandColorLight: UIColor = {
        return UIColor(red: 11.0/256.0, green: 207.0/256.0, blue: 221.0/256.0, alpha: 1.0)
    }()
    
    lazy var appBackgroundColor: UIColor = {
        return UIColor(red: 173.0/256.0, green: 216.0/256.0, blue: 244.0/256.0, alpha: 1.0)
    }()
    
    lazy var blackColor: UIColor = {
        return UIColor(red: 3.0/256.0, green: 11.0/256.0, blue: 64.0/256.0, alpha: 1.0)
    }()
    
    lazy var subtitleColor: UIColor = {
        return UIColor(red: 1/0/256, green: 250.0/256.0, blue: 202.0/256.0, alpha: 1.0)
    }()
    
    var bodyTextColor: UIColor {
        return self.blackColor
    }
    
    var subTitleColor: UIColor {
        return self.brandColorLight
    }
    
    func setupAppearanceProxies() {
        
        UINavigationBar.appearance().barTintColor = self.brandColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        UITabBar.appearance().barTintColor = self.brandColor
        UITabBar.appearance().tintColor = self.brandColorLight
    }
    
    
    
    
}