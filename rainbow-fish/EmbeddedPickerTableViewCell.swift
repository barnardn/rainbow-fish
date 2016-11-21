//
//  EmbeddedPickerTableViewCell.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/7/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

protocol EmbeddedPickerTableViewCellDataSource: class {

    func numberOfRowsForEmbeddedPickerTableViewCell(_ cell: EmbeddedPickerTableViewCell) -> Int
}

protocol EmbeddedPickerTableViewCellDelegate: class {
    func embeddedPickerTableViewCell(_ cell: EmbeddedPickerTableViewCell, selectedItemAtIndex index: Int)
    func embeddedPickerTableViewCell(_ cell: EmbeddedPickerTableViewCell, titleForRow row: Int) -> String
}

class EmbeddedPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var pickerView: UIPickerView!

    weak var delegate: EmbeddedPickerTableViewCellDelegate?
    weak var dataSource: EmbeddedPickerTableViewCellDataSource? {
        get {
            return self.dataSource
        }
        set {
            self.dataSource = newValue
            self.pickerView.reloadAllComponents()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.pickerView.delegate = self
    }
}

extension EmbeddedPickerTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: pickerview data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let dataSource = self.dataSource {
            return dataSource.numberOfRowsForEmbeddedPickerTableViewCell(self)
        }
        return 0
    }
    
    // MARK: pickerview delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let delegate = self.delegate {
            return delegate.embeddedPickerTableViewCell(self, titleForRow: row)
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let delegate = self.delegate {
            return delegate.embeddedPickerTableViewCell(self, selectedItemAtIndex: row)
        }
    }
    
}
