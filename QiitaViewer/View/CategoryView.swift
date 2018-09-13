//
//  CategoryView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/14.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noCategoryView: UIView!
    
    var categories: Results<Category>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.title = "Categories"
        checkCategories()
    }
    
    func checkCategories() {
        categories = try! Realm().objects(Category.self)
        if categories.count > 0 {
            noCategoryView.isHidden = true
        } else {
            noCategoryView.isHidden = false
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let view = UIStoryboard(name: "CategoryArticle", bundle: nil).instantiateViewController(withIdentifier: "CategoryArticleBoard") as! CategoryArticleView
        view.name = categories[indexPath.row].name
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Categories", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realm = try! Realm()
            try! realm.write {
                realm.delete(categories[indexPath.row])
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            checkCategories()
        }
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let realm = try! Realm()
        
        let alert = UIAlertController(title: "Add Categoy", message: "Enter name", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Category Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            if let fields = alert.textFields {
                for name in fields {
                    if realm.objects(Category.self).filter("name == %@", name.text!).count > 0 {
                        let alert = UIAlertController(title: "Error", message: "This name is already added", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    let category = Category()
                    category.name = name.text
                    try! realm.write {
                        realm.add(category)
                    }
                    self.checkCategories()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
