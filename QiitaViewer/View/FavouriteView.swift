//
//  FavouriteView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/04/10.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class FavouriteView: UITableViewController {

    var favourites: Results<Articles>!
    
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.title = "Favourites"
        self.tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFavourite()
    }
    
    func getFavourite() -> Void {
        let realm = try! Realm()
        favourites = realm.objects(Articles.self)
        for data in favourites {
            print(data.image as Any)
            Alamofire.request(data.image!).responseData { response in
                print("response: \(response.result)")
                switch response.result {
                case .success:
                    if let image = UIImage(data: response.data!) {
                        self.images.append(image)
                    } else {
                        self.images.append(UIImage(named: "ic_image")!)
                    }
                case .failure(_):
                    self.images.append(UIImage(named: "ic_image")!)
                }
                if self.images.count == self.favourites.count {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func addClick(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Add folder", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        //textfiledの追加
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            let realm = try! Realm()
            if realm.objects(Folders.self).filter("folder = %@", text.text as Any).count == 0 {
                let data = Folders()
                data.folder = text.text
                try! realm.write {
                    realm.add(data)
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
        view.articleID = favourites[indexPath.row].id
        view.articleTitle = favourites[indexPath.row].title
        view.articleUrl = favourites[indexPath.row].url
        view.articleBody = favourites[indexPath.row].body
        view.articleImage = favourites[indexPath.row].image
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
        cell.title.text = favourites[indexPath.row].title
        if images.count != favourites.count {
            cell.thumbnail.image = UIImage(named: "ic_image")
        } else {
            cell.thumbnail.image = images[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
