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

class FavouriteView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var favourites: Results<Articles>!
    
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = "Favourites"
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
        let alert = UIAlertController(title: nil, message: "Add folder", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewBoard") as! WebViewer
        view.articleID = favourites[indexPath.row].id
        view.articleTitle = favourites[indexPath.row].title
        view.articleUrl = favourites[indexPath.row].url
        view.articleBody = favourites[indexPath.row].body
        view.articleImage = favourites[indexPath.row].image
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Favourites", for: indexPath)
        cell.textLabel?.text = favourites[indexPath.row].title
        if images.count != favourites.count {
            cell.imageView?.image = UIImage(named: "ic_image")
        } else {
            cell.imageView?.image = images[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
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
