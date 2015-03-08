//
//  InventorySearchResultsController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 3/7/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class InventorySearchResultsTableViewController: UITableViewController {

    var searchResults = [Inventory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: InventoryTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: InventoryTableViewCell.nibName)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(InventoryTableViewCell.nibName, forIndexPath: indexPath) as InventoryTableViewCell
        let lineItem = self.searchResults[indexPath.row]
        cell.title = lineItem.name
        if let qty = lineItem.quantity {
            cell.quantity = qty.stringValue
        }
        if let productName = lineItem.productName {
            if let pencilIdent = lineItem.pencilIdentifier {
                cell.subtitle = "\(productName) \(pencilIdent)"
            }
        }
        cell.swatchColor = lineItem.color as? UIColor
        return cell
    }


}
