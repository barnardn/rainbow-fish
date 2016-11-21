//
//  PencilSearchResultsTableViewController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/18/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class PencilSearchResultsTableViewController: UITableViewController {

    var searchResults = [Pencil]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: DefaultDetailTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: DefaultDetailTableViewCell.nibName)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DefaultDetailTableViewCell.nibName, for: indexPath) as! DefaultDetailTableViewCell
        let pencil = searchResults[indexPath.row]
        cell.textLabel?.text = pencil.name;
        cell.detailTextLabel?.text = pencil.identifier
        cell.accessoryType = .disclosureIndicator
        return cell
    }

}
