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
import RxSwift

class CategoryArticleView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var articles: [Articles] = []
    var name: String!
    
    var images: [UIImage] = []
    let disposeBag = DisposeBag()
    
    var previousVal = 0
    
    @IBOutlet weak var noArticleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = name
        tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkArticles()
    }
    
    func checkArticles() {
        if try! Realm().objects(Category.self).filter("name == %@", name).first?.articles.count == 0 {
            noArticleView.isHidden = false
        } else {
            noArticleView.isHidden = true
            getArticles()
        }
    }
    func getArticles() -> Void {
        if previousVal == (try! Realm().objects(Category.self).filter("name == %@", name).first?.articles.count) {
            return
        }
        let realm = try! Realm()
        let category = realm.objects(Category.self).filter("name == %@", name).first
        let group = DispatchGroup()
        category!.articles.forEach { (article) in
            print("enter")
            group.enter()
            UserInfoRequest.sharedInstance.getProfileImage(url: article.image!).subscribe(onNext: { (image) in
                self.images.append(image)
            }, onError: { (error) in
                self.images.append(UIImage(named: "ic_image")!)
            }, onCompleted: {
                
            }, onDisposed: {
                self.articles.append(article)
                group.leave()
            }).disposed(by: disposeBag)
        }
        group.notify(queue: .main) {
            self.previousVal = self.articles.count
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addClick(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Add folder", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        //textfiledの追加
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            let realm = try! Realm()
            if realm.objects(Category.self).filter("folder = %@", text.text as Any).count == 0 {
                let category = Category()
                category.name = text.text
                try! realm.write {
                    realm.add(category)
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
        view.articleID = articles[indexPath.row].id
        view.articleTitle = articles[indexPath.row].title
        view.articleUrl = articles[indexPath.row].url
        view.articleImage = articles[indexPath.row].image
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
        cell.setData(thumbnail: images[indexPath.row], user_id: articles[indexPath.row].user_id!, title: articles[indexPath.row].title!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
