//
//  CategoryViewController.swift
//  ToDoey
//
//  Created by Ruurd Pels on 23-05-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {

    let CATEGORYCELL = "CategoryCell"
    let ITEMSEGUE = "goToItems"

    let realm = try! Realm()


    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        loadCategories()
    }

    // ---------------------------------------------------------------------------
    // MARK: - TableView datasource methods
    // ---------------------------------------------------------------------------
    // Make sure you override the methods that are coming from the UITableViewDataSource protocol
    // instead of overriding the regular methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CATEGORYCELL, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        return cell
    }

    // ---------------------------------------------------------------------------
    // MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ITEMSEGUE, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedCategory = categories?[indexPath.row]
        }
    }

    // ---------------------------------------------------------------------------
    // MARK: - CRUD actions
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category: \(error)")
        }
        tableView.reloadData()
    }

    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }

    // ---------------------------------------------------------------------------
    // MARK: - Add new category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() // Pull the text field in the alert out of its scope so we can access it.

        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            // add the item to the array
            if let t = textField.text {
                let newCategory = Category()
                newCategory.name = t
                self.save(category: newCategory)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// ---------------------------------------------------------------------------
// MARK: - SwipeTableViewCellDelegate extension
extension CategoryViewController: SwipeTableViewCellDelegate {
    func visibleRect(for tableView: UITableView) -> CGRect? {
        return CGRect(x: 0, y: 0, width: 80, height: 80)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if let category = self.categories?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(category)
                    }
                } catch {
                    print("Cannot delete category: \(error)")
                }
                self.tableView.reloadData()
            }
        }

        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }
}
