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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    convenience init(pencil: Pencil?, context: NSManagedObjectContext) {
        self.init(style: UITableViewStyle.Grouped)
        self.title = NSLocalizedString("Add a Pencil", comment:"select pencil view title")
        self.context = context
        if let editPencil = pencil {
            self.pencil = editPencil
        } else {
            self.pencil = Pencil(managedObjectContext: context)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: EditPecilPropertyTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: EditPecilPropertyTableViewCell.nibName)
        self.tableView.registerNib(UINib(nibName: PencilColorPickerTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: PencilColorPickerTableViewCell.nibName)
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
            return cell
        }
        var cell = tableView.dequeueReusableCellWithIdentifier(PencilColorPickerTableViewCell.nibName, forIndexPath: indexPath) as PencilColorPickerTableViewCell
        cell.defaultColor = self.pencil.color as UIColor? ?? UIColor.blackColor()
        return cell
    }
}

// MARK: - Table view delegate
extension EditPencilTableViewController: UITableViewDelegate {
    
}