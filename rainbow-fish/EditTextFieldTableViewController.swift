//
//  EditTextFieldTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/21/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

typealias EditTextFieldTableViewCompletionBlock = (didSave: Bool, edittedText: String?) -> Void

class EditTextFieldTableViewController: UITableViewController {

    private var defaultText: String?
    private var placeholder: String?
    private var completion: EditTextFieldTableViewCompletionBlock?
    
    lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("barButtonTapped:"))
        return button
    }()
    
    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("barButtonTapped:"))
        return button
    }()
    
    convenience init(title: String, defaultText: String?, placeholder: String?, completion: EditTextFieldTableViewCompletionBlock?) {
        self.init(style: .Grouped)
        self.title = title
        self.defaultText = defaultText
        self.placeholder = placeholder
        self.completion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: TextFieldTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: TextFieldTableViewCell.nibName)
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor;
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.doneButton
        self.doneButton.enabled = (self.defaultText?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0)
    }
    
    func barButtonTapped(sender: UIBarButtonItem) {
        if let block = self.completion as EditTextFieldTableViewCompletionBlock? {
            if sender == self.cancelButton {
                block(didSave: false, edittedText: self.defaultText)
            } else {
                block(didSave: true, edittedText: self.defaultText)
            }
        }
    }
    
}

// MARK: - Table view data source

extension EditTextFieldTableViewController: UITableViewDataSource {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TextFieldTableViewCell.nibName, forIndexPath: indexPath) as TextFieldTableViewCell
        cell.defaultText = self.defaultText
        cell.placeholder = self.placeholder
        cell.delegate = self
        return cell
    }

}

extension EditTextFieldTableViewController: TextFieldTableViewCellDelegate {
    
    func textFieldTableViewCell(cell: TextFieldTableViewCell, changedText: String?) {
        self.defaultText = changedText
        if let text = self.defaultText {
            self.doneButton.enabled = (text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0)
        } else {
            self.doneButton.enabled = false
        }
        
    }
    
}