//
//  SelectManufacturerTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/7/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit
import CoreData
import CoreDataKit

class SelectManufacturerTableViewController: UITableViewController {

    var viewModel: PencilDataViewModel?
    var manufacturers: [Manufacturer]?
    
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
        self.title = NSLocalizedString("Select Manufacturer", comment:"select manufacturer nav bar title")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = AppearanceManager.appearanceManager.appBackgroundColor
        self.tableView.registerNib(UINib(nibName: DefaultTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultTableViewCell.nibName)
        let byName = NSSortDescriptor(key: ManufacturerAttributes.name.rawValue, ascending: true)

        let result = viewModel!.childContext.find(Manufacturer.self, predicate: nil, sortDescriptors: [byName], limit: nil, offset: nil)
        switch result {
        case let .Failure(error):
            assertionFailure(error.localizedDescription)
        case let .Success(boxedResults):
            var results = boxedResults()
            manufacturers = results
            tableView.reloadData()
        }
    }

}

extension SelectManufacturerTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let manufacturers = self.manufacturers {
            return manufacturers.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DefaultTableViewCell.nibName, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.font = AppearanceManager.appearanceManager.standardFont
        cell.textLabel?.textColor = AppearanceManager.appearanceManager.bodyTextColor
        cell.accessoryType = .None
        
        if let manufacturers = self.manufacturers {
            let m = manufacturers[indexPath.row]
            if m.objectID == viewModel?.manufacturer?.objectID {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                cell.accessoryType = .Checkmark
            }
            cell.textLabel?.text = m.name
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let manufacturers = self.manufacturers {
            viewModel?.manufacturer = manufacturers[indexPath.row]
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
        }
    }
    
    
    
}