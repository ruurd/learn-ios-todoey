//
//  CategoryViewController.swift
//  ToDoey
//
//  Created by Ruurd Pels on 23-05-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    let CATEGORYCELL = "CategoryCell"
    let ITEMSEGUE = "goToItems"

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadCategories()
    }

    // MARK: - TableView datasource methods
    // Make sure you override the methods that are coming from the UITableViewDataSource protocol
    // instead of overriding the regular methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CATEGORYCELL, for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }

    // MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ITEMSEGUE, sender: self)
        // Fetch row
        // Determine category
        // Segue to TodoListViewController
        // Select only items from category
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedCategory = categories[indexPath.row]
        }
    }

    // MARK: - Data manipulation methods
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category context: \(error)")
        }
        tableView.reloadData()
    }

    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)

        } catch {
            print("Error fetching categories from context \(error)")
        }
        tableView.reloadData()
    }

    // MARK: - Add new category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() // Pull the text field in the alert out of its scope so we can access it.

        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            // add the item to the array
            if let t = textField.text {
                let newCategory = Category(context: self.context)
                newCategory.name = t
                self.categories.append(newCategory)
                self.saveCategories()
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
