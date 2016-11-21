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
        self.tableView.register(UINib(nibName: InventoryTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: InventoryTableViewCell.nibName)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = InventoryTableViewCell.estimatedRowHeight
        self.tableView.tableFooterView = UIView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InventoryTableViewCell.nibName, for: indexPath) as! InventoryTableViewCell
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
