//
//  ProductFooterView.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/8/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

protocol ProductFooterViewDelegate : class {
    func productFooterView(_ view: ProductFooterView, newProductForManufacturer manufacturer: Manufacturer)
}


class ProductFooterView: UITableViewHeaderFooterView {
    
    weak var delegate: ProductFooterViewDelegate?
    
    var manufacturer: Manufacturer?
    
    lazy var addButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.setTitle(NSLocalizedString("+ Add Product", comment:"all pencils footer view button title"), for: UIControlState())
        button.setTitleColor(AppearanceManager.appearanceManager.brandColor, for: UIControlState())
        button.setTitleColor(AppearanceManager.appearanceManager.tableHeaderColor, for: .highlighted)
        button.titleLabel?.font = AppearanceManager.appearanceManager.subtitleFont
        button.addTarget(self, action: #selector(SelectPencilTableViewController.addButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.addButton)
        self.contentView.backgroundColor = UIColor.white
        self.isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        self.contentView.frame = self.bounds
        self.addButton.frame = CGRect(x: 10.0, y: 0.0, width: 100.0, height: ProductFooterView.footerHeight)
    }
    
    //MARK: button actions
    
    func addButtonTapped(_ sender: UIButton) {
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
