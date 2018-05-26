//
//  CategoryViewController.swift
//  ToDoey
//
//  Created by Ruurd Pels on 23-05-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let ITEMSEGUE = "goToItems"

    let realm = try! Realm()

    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavbarColorFrom(basicColor: UIColor.flatSkyBlue())
        tableView.backgroundColor = UIColor.flatSkyBlue()
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.bgcolor)
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor, isFlat: true)
        } else {
            cell.textLabel?.text =  "No categories added yet"
        }
        return cell
    }

    override func updateModel(at indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category)
                }
            } catch {
                print("Cannot delete category: \(error)")
            }
        }
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
                newCategory.bgcolor = UIColor.randomFlat().hexValue()
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
