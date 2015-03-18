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
    
    // MARK: colors
    
    lazy var brandColor: UIColor = {
        return UIColor(red: 11.0/256.0, green: 163.0/256.0, blue: 244.0/256.0, alpha: 1.0)
    }()
    
    lazy var brandColorAlternate: UIColor = {
        return UIColor(red: 30.0/256.0, green: 1.0/256.0, blue: 250.0/256.0, alpha: 1.0)
    }()
    
    lazy var appBackgroundColor: UIColor = {
        return UIColor(red: 248.0/256.0, green: 248.0/256.0, blue: 254.0/256.0, alpha: 1.0)
    }()
    
    lazy var blackColor: UIColor = {
        return UIColor(red: 3.0/256.0, green: 11.0/256.0, blue: 64.0/256.0, alpha: 1.0)
    }()
    
    lazy var strokeColor: UIColor = {
        return UIColor(white: 0.0, alpha: 0.05)
    }()
    
    lazy var selectedCellBackgroundColor: UIColor = {
        return UIColor(red: 1.0/256.0, green: 161.0/256.0, blue: 221.0/256.0, alpha: 1.0)
    }()
    
    var bodyTextColor: UIColor {
        return self.blackColor
    }
    
    var disabledTitleColor: UIColor {
        return UIColor(white: 0.0, alpha: 0.15)
    }
    
    var subTitleColor: UIColor {
        return self.brandColorAlternate
    }
    
    var tableHeaderColor: UIColor {
        return UIColor(white: 0.45, alpha: 1.0)
    }
    
    // MARK: fonts
    
    var standardFont: UIFont {
        return UIFont.systemFontOfSize(16.0)
    }
    
    var subtitleFont: UIFont {
        return UIFont.systemFontOfSize(12.0)
    }
    
    var nameLabelFont: UIFont {
        return UIFont.systemFontOfSize(14.0)
    }
    
    var headlineFont: UIFont {
        return UIFont.systemFontOfSize(24.0)
    }
    
    // MARK: methods
    
    func setupAppearanceProxies() {
        
        UINavigationBar.appearance().barTintColor = self.brandColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UITabBar.appearance().tintColor = self.brandColor
        UITextField.appearance().tintColor = self.brandColor
    }
    
    
    
    
}