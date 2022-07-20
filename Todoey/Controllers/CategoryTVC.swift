//
//  CategoryTVC.swift
//  Todoey
//
//  Created by Stas Bezhan on 18.07.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryTVC: UITableViewController {

    var arrayOfCategories: [Cats] = []
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    //refreshing table view
    @objc func refresh(_ sender: AnyObject) {
        loadCategories()
        self.refreshControl?.endRefreshing()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        //new alert
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        alert.addTextField() {(alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
            if alertTextField.text != nil && alertTextField.text != "" {
                textField.text = alertTextField.text
            }
        }
        
        //actions for alert
        let add = UIAlertAction(title: "Add", style: .default) { [weak self] (action) in
            if self?.context != nil {
                let newCategory = Cats(context: self!.context)
                newCategory.name = textField.text!
                self?.arrayOfCategories.append(newCategory)
                self?.saveCategories()
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {(UIAlertAction) in
            self.dismiss(animated: true)
        }
        //adding actions to alert
        alert.addAction(cancel)
        alert.addAction(add)
        //presenting alert
        DispatchQueue.main.async {[weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCategories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIf, for: indexPath)
        let category = arrayOfCategories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    
    //MARK: - TableViewDelegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TableView {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.selectedCategory = arrayOfCategories[indexPath.row]
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segueID, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Data manipulation
    
    func loadCategories(for request: NSFetchRequest<Cats> = Cats.fetchRequest()) {
        do {
            arrayOfCategories = try context.fetch(request)
            saveCategories()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func saveCategories() {
        do {
            try context.save()
            self.tableView.reloadData()
        }catch{
            print(error.localizedDescription)
        }
    }
}

