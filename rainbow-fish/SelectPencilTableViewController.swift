//
//  SelectPencilTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/8/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit
import CoreData
import CoreDataKit

class SelectPencilTableViewController: UITableViewController {

    var viewModel: PencilDataViewModel?
    var pencils: [Pencil]?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    convenience init(viewModel: PencilDataViewModel) {
        self.init(style: UITableViewStyle.Plain)
        self.viewModel = viewModel
        self.title = NSLocalizedString("Add a Pencil", comment:"select pencil view title")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.allowsMultipleSelection = true
        self.tableView.registerNib(UINib(nibName: DefaultDetailTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultDetailTableViewCell.nibName)
        updatePencils()
    }
    
    func updatePencils() {
        var modificationDate: NSDate?
        if let pencils = Pencil.allPencils(forProduct: self.viewModel!.product!, context: self.viewModel!.childContext) {
            self.pencils = pencils
            modificationDate = recentModificationDate(inPencils: pencils)
            tableView.reloadData()
        }
        self.showHUD(header: "Refreshing Pencils", footer: "Please Wait...")
        CloudManager.sharedManger.importPencilsForProduct(viewModel!.product!, modifiedAfterDate: modificationDate ){ (success, error) in
            self.hideHUD()
            if error != nil {
                println(error?.localizedDescription)
            } else {
                self.pencils = Pencil.allPencils(forProduct: self.viewModel!.product!, context: self.viewModel!.childContext)
                self.tableView.reloadData()
            }
        }
    }
    
    func recentModificationDate(inPencils pencils: [Pencil]) -> NSDate {
        let newestPencil =  pencils.reduce(pencils.first!) { (p1: Pencil, p2: Pencil) -> Pencil in
            let date1 = p1.modificationDate!
            let date2 = p2.modificationDate!
            if date1.compare(date2) == NSComparisonResult.OrderedDescending {
                return p1
            }
            return p2
        }
        return newestPencil.modificationDate!
    }

}

// MARK: UITableViewDataSource

extension SelectPencilTableViewController: UITableViewDataSource {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let pencils = self.pencils {
            return pencils.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DefaultDetailTableViewCell.nibName, forIndexPath: indexPath) as DefaultDetailTableViewCell
        cell.accessoryType = .None
        if let pencil = self.pencils?[indexPath.row] {
            if pencil.isNew!.boolValue && containsSelectedIndexPath(indexPath) {
                cell.accessoryType = .Checkmark
            }
            cell.textLabel?.text = pencil.name
            cell.detailTextLabel?.text = pencil.identifier
        }
        return cell
    }

    private func containsSelectedIndexPath(indexPath: NSIndexPath) -> Bool {
        if let selected = self.tableView.indexPathsForSelectedRows() as [NSIndexPath]? {
            var match = selected.filter{idxPath in
                return (indexPath == idxPath)
            }
            return (match.count > 0)
        }
        return false
    }
    
}


// MARK: UITableViewDelegate

extension SelectPencilTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as DefaultDetailTableViewCell
        cell.accessoryType = .None
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as DefaultDetailTableViewCell
        cell.accessoryType = .Checkmark
    }
    
}
