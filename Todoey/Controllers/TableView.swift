//
//  TableView.swift
//  Todoey
//
//  Created by Stas Bezhan on 12.07.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit

class TableView: UITableViewController {
    
    var itemsArray = ["Find money", "Call mom", "Drink tea"]
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let items = defaults.array(forKey: K.userDefaults) as? [String]{
        itemsArray = items
    }
}
    
    //Adding new items to List
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        //adding alert for pressing button
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        //adding textfield when alert presented
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            if alertTextField.text != nil && alertTextField.text != "" {
                textField.text = alertTextField.text
            }
        }
        //action after configuring new item in textfield
        let action = UIAlertAction(title: "Add Item", style: .default) {(action) in
                if textField.text != nil && textField.text != "" {
                    self.itemsArray.append(textField.text!)
                    self.defaults.set(self.itemsArray, forKey: K.userDefaults)
                    self.tableView.reloadData()
            }
        }
        //adding an action to alert
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
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
        cell.textLabel?.text = itemsArray[indexPath.row]
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        print(itemsArray[indexPath.row])
        
    }
}


