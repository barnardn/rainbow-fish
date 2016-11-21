//
//  EditTextFieldTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/21/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


typealias EditTextFieldTableViewCompletionBlock = (_ didSave: Bool, _ edittedText: String?, _ sender: UIBarButtonItem?) -> Void

class EditTextFieldTableViewController: UITableViewController {

    fileprivate var defaultText: String?
    fileprivate var placeholder: String?
    fileprivate var completion: EditTextFieldTableViewCompletionBlock?
    
    lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditTextFieldTableViewController.barButtonTapped(_:)))
        return button
    }()
    
    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(EditTextFieldTableViewController.barButtonTapped(_:)))
        return button
    }()
    
    convenience init(title: String, defaultText: String?, placeholder: String?, completion: EditTextFieldTableViewCompletionBlock?) {
        self.init(style: .grouped)
        self.title = title
        self.defaultText = defaultText
        self.placeholder = placeholder
        self.completion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: TextFieldTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: TextFieldTableViewCell.nibName)
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor;
        self.navigationItem.leftBarButtonItem = self.cancelButton
        if self.defaultText?.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            self.navigationItem.rightBarButtonItem = self.doneButton
        }
    }
    
    func barButtonTapped(_ sender: UIBarButtonItem) {
        self.tableView.endEditing(true)
        if let block = self.completion as EditTextFieldTableViewCompletionBlock? {
            if sender == self.cancelButton {
                block(false, self.defaultText, nil)
            } else {
                block(true, self.defaultText, sender)
            }
        }
    }
    

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.nibName, for: indexPath) as! TextFieldTableViewCell
        cell.defaultText = self.defaultText
        cell.placeholder = self.placeholder
        cell.delegate = self
        return cell
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.becomeFirstResponder()
    }
}


extension EditTextFieldTableViewController: TextFieldTableViewCellDelegate {
    
    func textFieldTableViewCell(_ cell: TextFieldTableViewCell, changedText: String?) {
        self.defaultText = changedText
        if let text = self.defaultText {
            let barButtonItem: UIBarButtonItem? = (text.lengthOfBytes(using: String.Encoding.utf8) > 0) ? self.doneButton : nil
            self.navigationItem.setRightBarButton(barButtonItem, animated: true)
        } else {
            self.navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
}
