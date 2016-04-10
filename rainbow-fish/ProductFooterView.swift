//
//  ProductFooterView.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/8/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

protocol ProductFooterViewDelegate : class {
    func productFooterView(view: ProductFooterView, newProductForManufacturer manufacturer: Manufacturer)
}


class ProductFooterView: UITableViewHeaderFooterView {
    
    weak var delegate: ProductFooterViewDelegate?
    
    var manufacturer: Manufacturer?
    
    lazy var addButton: UIButton = {
        let button = UIButton(frame: CGRectZero)
        button.setTitle(NSLocalizedString("+ Add Product", comment:"all pencils footer view button title"), forState: .Normal)
        button.setTitleColor(AppearanceManager.appearanceManager.brandColor, forState: .Normal)
        button.setTitleColor(AppearanceManager.appearanceManager.tableHeaderColor, forState: .Highlighted)
        button.titleLabel?.font = AppearanceManager.appearanceManager.subtitleFont
        button.addTarget(self, action: #selector(SelectPencilTableViewController.addButtonTapped(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.addButton)
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.userInteractionEnabled = true
    }

    override func layoutSubviews() {
        self.contentView.frame = self.bounds
        self.addButton.frame = CGRectMake(10.0, 0.0, 100.0, ProductFooterView.footerHeight)
    }
    
    //MARK: button actions
    
    func addButtonTapped(sender: UIButton) {
        if let delegate = self.delegate {
            if let manufacturer = self.manufacturer {
                delegate.productFooterView(self, newProductForManufacturer: manufacturer)
            }
        }
    }
    
    //MARK: class methods
    
    class var footerHeight: CGFloat {
        return 24.0
    }
    
    
}
