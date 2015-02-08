//
//  SelectPencilTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/8/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.allowsMultipleSelection = true
        self.tableView.registerNib(UINib(nibName: DefaultDetailTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultDetailTableViewCell.nibName)
        pencils = viewModel?.product?.sortedPencils()
        tableView.reloadData()
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
