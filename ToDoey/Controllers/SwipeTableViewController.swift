//
//  SwipeTableViewController.swift
//  ToDoey
//
//  Created by Ruurd Pels on 25-05-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    let SWIPETABLECELL = "SwipeTableCell"
    let ROWHEIGHT = CGFloat(70)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = ROWHEIGHT
        tableView.separatorStyle = .none
    }

    func visibleRect(for tableView: UITableView) -> CGRect? {
        return nil
    }

    func setNavbarColorFrom(basicColor: UIColor) {
        guard let navbar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        navbar.barTintColor = basicColor
        navbar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: basicColor, isFlat: true)
        navbar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: basicColor, isFlat: true)]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SWIPETABLECELL, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updateModel(at: indexPath)
        }
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }

    func updateModel(at indexPath: IndexPath) {
        print("Implement this method to make it work")
    }
}
