//
//  ViewController.swift
//  ToDoey
//
//  Created by Ruurd Pels on 22-05-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {

    let realm = try! Realm()

    @IBOutlet weak var searchBar: UISearchBar!
    var todos: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = selectedCategory?.name
        if let hex = selectedCategory?.bgcolor {
            setNavbarColorFrom(basicColor: UIColor(hexString: hex))
            searchBar.barTintColor = UIColor(hexString: hex)
            tableView.backgroundColor = UIColor(hexString: hex)
        }
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todos?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.backgroundColor = UIColor(hexString: selectedCategory!.bgcolor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todos!.count))
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor, isFlat: true)
            cell.accessoryType = item.done ? .checkmark : .none
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

    override func updateModel(at indexPath: IndexPath) {
        if let todo = todos?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(todo)
                }
            } catch {
                print("Cannot delete todo: \(error)")
            }
        }
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
