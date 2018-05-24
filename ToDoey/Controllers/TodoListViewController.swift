//
//  ViewController.swift
//  ToDoey
//
//  Created by Ruurd Pels on 22-05-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class TodoListViewController: UITableViewController {

    let TODOITEMCELL = "TodoItemCell"

    let realm = try! Realm()

    var todos: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
    }

    // ---------------------------------------------------------------------------
    // MARK: - Tabelview Datasource Methods
    // ---------------------------------------------------------------------------
    // Make sure you override the methods that are coming from the UITableViewDataSource protocol
    // instead of overriding the regular methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TODOITEMCELL, for: indexPath) as! SwipeTableViewCell
        if let item = todos?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            cell.delegate = self
        } else {
            cell.textLabel?.text = "No items yet"
        }
        return cell
    }

    // ---------------------------------------------------------------------------
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todos?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                    if item.done {
                        item.dateFinished = Date()
                    } else {
                        item.dateFinished = Date.init(timeIntervalSince1970: 0)
                    }
                }
            } catch {
                print("Error saving done status: \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // ---------------------------------------------------------------------------
    // MARK: - Add a new item to the array and persist
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() // Pull the text field in the alert out of its scope so we can access it.

        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            if let t = textField.text {
                if let category = self.selectedCategory {
                    do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = t
                        category.items.append(newItem)
                    }
                    } catch {
                        print("Error saving item: \(error)")
                    }
                }
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func loadItems() {
        todos = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
}

extension TodoListViewController: SwipeTableViewCellDelegate {
    func visibleRect(for tableView: UITableView) -> CGRect? {
        return CGRect(x: 0, y: 0, width: 80, height: 80)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if let todo = self.todos?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(todo)
                    }
                } catch {
                    print("Cannot delete item: \(error)")
                }
                self.tableView.reloadData()
            }
        }

        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }
}

// ---------------------------------------------------------------------------
// MARK: - Search bar extension
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todos = selectedCategory?.items.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
