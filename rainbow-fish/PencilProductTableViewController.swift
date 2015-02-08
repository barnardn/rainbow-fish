//
//  PencilProductTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/7/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class PencilProductTableViewController: UITableViewController {

    var sectionTitles: [[String]]?
    var viewModel: PencilDataViewModel?
    
    enum TableSections: NSInteger {
        case ManufacturerDetail, Pencil
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: .Grouped)
        sectionTitles = [[NSLocalizedString("Manufacturer", comment:"edit product manufacturer cell title")]]
        viewModel = PencilDataViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: NameValueTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: NameValueTableViewCell.nibName)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.separatorInset = UIEdgeInsetsZero
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneButtonTapped:"))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelButtonTapped:"))

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.title = NSLocalizedString("New Pencil", comment:"new pencil view controller navigation title")

    }
    
    // MARK: button actions
    
    func cancelButtonTapped(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension PencilProductTableViewController: UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sectionInfo = self.sectionTitles {
            return sectionInfo.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionInfo = self.sectionTitles {
            let sectionRows = sectionInfo[section]
            return sectionRows.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NameValueTableViewCell.nibName, forIndexPath: indexPath) as NameValueTableViewCell
        cell.name = titleForRowAtIndexPath(indexPath)
        cell.value = "Some Value Some Value Some Value Some Value Some Value Some Value"
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> String? {
        if let sectionInfo = self.sectionTitles {
            let sectionRows = sectionInfo[indexPath.section]
            return sectionRows[indexPath.row]
        }
        return nil
    }
    
}

extension PencilProductTableViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == TableSections.ManufacturerDetail.rawValue {
            if indexPath.row == 0 {
                self.navigationController?.pushViewController(SelectManufacturerTableViewController(viewModel: self.viewModel!), animated: true)
            }
        }
    }
    
}

