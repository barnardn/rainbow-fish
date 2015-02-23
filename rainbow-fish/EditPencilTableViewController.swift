//
//  EditPencilTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/15/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import CoreData
import CoreDataKit
import UIKit

class EditPencilTableViewController: UITableViewController {

    var pencil: Pencil!
    var context: NSManagedObjectContext!
    var readonly = true
    
    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: Selector("saveButonTapped:"))
        return button
    }()
    
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("editButtonTapped:"))
        return button
    }()

    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelButtonTapped:"))
        return button
    }()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    convenience init(pencil: Pencil?) {
        self.init(style: UITableViewStyle.Grouped)
        self.context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType, parentContext: CoreDataKit.mainThreadContext)
        if let editPencil = pencil {
            self.title = NSLocalizedString("Edit Pencil", comment:"edit an existing pencil view title")
            self.pencil = self.context.objectWithID(editPencil.objectID) as Pencil
        } else {
            self.readonly = false
            self.title = NSLocalizedString("New Pencil", comment:"new pencil view title")
            self.pencil = Pencil(managedObjectContext: self.context)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: EditPecilPropertyTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: EditPecilPropertyTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: PencilColorPickerTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorPickerTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: PencilColorTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorTableViewCell.nibName)
        if self.readonly {
            self.navigationItem.rightBarButtonItem = self.editButton
        } else {
            self.navigationItem.rightBarButtonItem = self.saveButton
        }
    }

    // MARK: button actions
    
    func editButtonTapped(sender: UIBarButtonItem) {
        self.readonly = false
        self.navigationItem.setRightBarButtonItem(self.saveButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(self.cancelButton, animated: true)
        self.tableView.reloadData()
    }

    func cancelButtonTapped(sender: UIBarButtonItem) {
        self.readonly = true
        self.navigationItem.setRightBarButtonItem(self.editButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        self.context.rollback()
        self.pencil = self.context.objectWithID(self.pencil.objectID) as Pencil
        self.tableView.reloadData()
    }
    
}

// MARK: - Table view data source
extension EditPencilTableViewController: UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 2 : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier(EditPecilPropertyTableViewCell.nibName, forIndexPath: indexPath) as EditPecilPropertyTableViewCell
            cell.pencil = self.pencil
            if indexPath.row == 0 {
                cell.placeholder = NSLocalizedString("Color Name", comment:"edit pencil color name placeholder")
                cell.keyPath = "name"
            } else {
                cell.placeholder = NSLocalizedString("Color Code e.g. PC1097", comment:"edit pencil color code placeholder")
                cell.keyPath = "identifier"
            }
            cell.readonly = self.readonly
            return cell
        } else {
            if self.readonly {
                var cell = tableView.dequeueReusableCellWithIdentifier(PencilColorTableViewCell.nibName, forIndexPath: indexPath) as PencilColorTableViewCell
                let color = self.pencil.color as? UIColor ?? UIColor.blackColor()
                cell.swatchColor = color
                cell.colorName = color.hexRepresentation
                return cell
            }
            var cell = tableView.dequeueReusableCellWithIdentifier(PencilColorPickerTableViewCell.nibName, forIndexPath: indexPath) as PencilColorPickerTableViewCell
            cell.defaultColor = self.pencil.color as UIColor? ?? UIColor.blackColor()
            cell.readonly = false
            return cell
        }
    }
}

// MARK: - Table view delegate
extension EditPencilTableViewController: UITableViewDelegate {
    
}