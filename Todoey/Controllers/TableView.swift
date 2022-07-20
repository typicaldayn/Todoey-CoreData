//
//  TableView.swift
//  Todoey
//
//  Created by Stas Bezhan on 12.07.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TableView: UITableViewController {
    
    var selectedCategory: Cats? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemsArray: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    //refreshing table view
    @objc func refresh(_ sender: AnyObject) {
        loadItems()
        self.refreshControl?.endRefreshing()
    }
    
    //Adding new items to List
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        //adding alert for pressing button
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        
        //action after configuring new item in textfield
        let action = UIAlertAction(title: "Add Item", style: .default) {[weak self] (action) in
            if textField.text != nil && textField.text != "" {
                let newItem = Item(context: self!.context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.categories = self?.selectedCategory
                self?.itemsArray.append(newItem)
                self?.saveItems()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { [weak self] (UIAlertAction) in
            self?.dismiss(animated: true)
        }
        
        //adding textfield when alert presented
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            if alertTextField.text != nil && alertTextField.text != "" {
                textField.text = alertTextField.text
            }
        }
        
        //adding an action to alert
        alert.addAction(action)
        alert.addAction(cancelAction)
        DispatchQueue.main.async {[weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func loadItems(for request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "categories.name MATCHES %@", selectedCategory!.name!)
        
        if let addittionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addittionalPredicate])
        }else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemsArray = try context.fetch(request)
            saveItems()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func saveItems() {
        do {
            try self.context.save()
            self.tableView.reloadData()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellId, for: indexPath)
        let item = itemsArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        
        //        context.delete(itemsArray[indexPath.row])
        //        itemsArray.remove(at: indexPath.row)
        
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - SearchBarDelegate:
extension TableView: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadItems(for: request, predicate: predicate)
//            do {
//                itemsArray = try context.fetch(request)
//            }catch{
//                print(error.localizedDescription)
//            }
        }
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

