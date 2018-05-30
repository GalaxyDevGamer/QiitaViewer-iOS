//
//  WebViewer.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/04/10.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RealmSwift
import WebKit
import Alamofire

class WebViewer: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var articleID: String?
    var articleTitle: String?
    var articleBody: String?
    var articleUrl: String?
    var articleImage: String?
    
    var isFavourite = false
    
    @IBOutlet var favouriteItem: UIBarButtonItem!
    @IBOutlet var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webView.load(URLRequest(url: URL(string: articleUrl!)!))
        checkFavourite()
//        favouriteItem.style = UIBarButtonItemStyle.plain
//        favouriteItem.image = getImage()
        favouriteItem = UIBarButtonItem(image: getImage(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(favourite(_:)))
        self.navigationItem.title = articleTitle
        self.navigationItem.rightBarButtonItem = favouriteItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favouriteClick(_ sender: Any) {
        let realm = try! Realm()
        if isFavourite {
            deleteFavourite()
        } else {
            let data = Articles()
            data.id = articleID
            data.title = articleTitle
            data.body = articleBody
            data.url = articleUrl
            data.image = articleImage
            try! realm.write {
                realm.add(data)
            }
            isFavourite = true
        }
        favouriteItem.image = getImage()
    }
    
    @objc func favourite(_ sender: Any) {
        let realm = try! Realm()
        if isFavourite {
            deleteFavourite()
        } else {
            let data = Articles()
            data.id = articleID
            data.title = articleTitle
            data.body = articleBody
            data.url = articleUrl
            data.image = articleImage
            try! realm.write {
                realm.add(data)
            }
            isFavourite = true
            Alamofire.request("https://qiita.com/api/v2/items/\(articleID)/stock", method: .put, parameters: nil, encoding: URLEncoding.default, headers: nil)
        }
        favouriteItem.image = getImage()
    }
    
    func getImage() -> UIImage {
        if isFavourite {
            return (UIImage(named: "ic_star")?.withRenderingMode(.alwaysOriginal))!
        } else {
            return (UIImage(named: "ic_star_border")?.withRenderingMode(.alwaysOriginal))!
        }
    }
    
    func checkFavourite() -> Void {
        if try! Realm().objects(Articles.self).filter("id = %@", articleID as Any).count > 0 {
            isFavourite = true
        } else {
            isFavourite = false
        }
    }
    
    func deleteFavourite() -> Void {
        let realm = try! Realm()
        let data = realm.objects(Articles.self).filter("id = %@", articleID as Any).first
        try! realm.write {
            realm.delete(data!)
        }
        isFavourite = false
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
