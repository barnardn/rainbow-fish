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

    var viewModel: PencilDataViewModel!
    var manufacturers: [Manufacturer]?
    
    lazy var addButton:  UIBarButtonItem = {
        var button = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addButtonTapped:"))
        return button
    }()
    
    convenience init(viewModel: PencilDataViewModel) {
        self.init(style: UITableViewStyle.Plain)
        self.viewModel = viewModel
        self.title = NSLocalizedString("Select Manufacturer", comment:"select manufacturer nav bar title")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorColor = AppearanceManager.appearanceManager.strokeColor
        self.tableView.registerNib(UINib(nibName: DefaultTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultTableViewCell.nibName)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.navigationItem.rightBarButtonItem = self.addButton
        
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
    
    
    //MARK: button action
    
    func addButtonTapped(sender: UIBarButtonItem) {
        let viewController = EditManufacturerNavigationController(manufacturer: nil) { (didSave, edittedText) -> Void in
            if didSave {
                if let name = edittedText {
                    let manufacturer = Manufacturer(managedObjectContext: self.viewModel.childContext)
                    manufacturer.name = name
                    var error: NSError?
                    let ok = self.viewModel.childContext.save(&error)
                    assert(ok, "unable to save: \(error?.localizedDescription)")
                    self.insertManufacturer(manufacturer)
                }
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    private func insertManufacturer(manufacturer: Manufacturer) {
        var row = 0
        self.viewModel.manufacturer = manufacturer
        if var manufacturers = self.manufacturers {
            let idx = manufacturers.insertionIndexOf(manufacturer, isOrderedBefore: { (m1: Manufacturer, m2: Manufacturer) -> Bool in
                let name1 = m1.name
                let name2 = m2.name
                return (name1!.localizedCaseInsensitiveCompare(name2!) == .OrderedAscending)
            })
            row = idx
            manufacturers.insert(manufacturer, atIndex: idx)
            self.manufacturers = manufacturers
        } else {
            self.manufacturers = [manufacturer]
        }
        var indexPath = NSIndexPath(forRow: row, inSection: 0)
        self.tableView.reloadData()
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: false)
    }

}

// MARK: -- UITableViewDataSource
extension SelectManufacturerTableViewController: UITableViewDataSource {
    
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
   
}

// MARK: -- UITableViewDelegate
extension SelectManufacturerTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let manufacturers = self.manufacturers {
            viewModel?.manufacturer = manufacturers[indexPath.row]
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
        }
    }
    
}


