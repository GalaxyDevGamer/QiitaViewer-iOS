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

class BrowserView: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var articleID: String?
    var articleTitle: String?
    var articleBody: String?
    var articleUrl: String?
    var articleImage: String?
    var user_id: String!
    
    var isStocked = false
    var isLiked = false
    
    @IBOutlet weak var stock: UIBarButtonItem!
    @IBOutlet weak var like: UIBarButtonItem!
    @IBOutlet var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        checkStock()
        checkLike()
        if UserDefaults.standard.string(forKey: "id") == nil {
            NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: NSNotification.Name("loginSuccess"), object: nil)
        }
    }
    
    func getAccessToken() -> String {
        return "Bearer " + UserDefaults.standard.string(forKey: "access_token")!
    }
    
    func checkStock() {
        if UserDefaults.standard.string(forKey: "access_token") == nil {
            return
        }
        Alamofire.request(HOST+"/items/\(articleID!)/stock", method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":getAccessToken()]).response { (response) in
            if response.response?.statusCode == 204 {
                self.stock.image = UIImage(named: "Stocked24pt")
                self.isStocked = true
            }
        }
    }
    
    func checkLike() {
        if UserDefaults.standard.string(forKey: "access_token") == nil {
            return
        }
        Alamofire.request(HOST+"/items/\(articleID!)/like", method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":getAccessToken()]).response { (response) in
            if response.response?.statusCode == 204 {
                self.like.image = UIImage(named: "Liked24pt")
                self.isLiked = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        webView.load(URLRequest(url: URL(string: articleUrl!)!))
        self.navigationItem.title = articleTitle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loginSuccess() {
        showDialog(title: "", message: "Login Success")
    }
    
    @IBAction func stockClick(_ sender: Any) {
        if UserDefaults.standard.string(forKey: "id") == nil {
            needToLogin(target: "stock")
            return
        }
        if isStocked {
            Alamofire.request(HOST+"/items/\(articleID!)/stock", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":getAccessToken()]).response { (response) in
                if response.response?.statusCode == 204 {
                    self.stock.image = UIImage(named: "UnStocked24pt")
                    self.isStocked = false
                    self.showDialog(title:"", message: "UnStocked")
                } else {
                    self.showDialog(title: FailTitle, message: "UnStock failed.")
                }
            }
        } else {
            Alamofire.request(HOST+"/items/\(articleID!)/stock", method: .put, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":getAccessToken()]).response { (response) in
                if response.response?.statusCode == 204 {
                    self.stock.image = UIImage(named: "Stocked24pt")
                    self.isStocked = true
                    self.showDialog(title: "", message: "Stocked")
                } else {
                    self.showDialog(title: FailTitle, message: "Stock failed")
                }
            }
        }
    }
    
    @IBAction func likeClick(_ sender: Any) {
        if UserDefaults.standard.string(forKey: "id") == nil {
            needToLogin(target: "like")
            return
        }
        if isLiked {
            Alamofire.request(HOST+"/items/\(articleID!)/like", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":getAccessToken()]).response { (response) in
                if response.response?.statusCode == 204 {
                    self.like.image = UIImage(named: "UnLiked24pt")
                    self.isLiked = false
                    self.showDialog(title: "", message: "UnLiked")
                } else {
                    self.showDialog(title: FailTitle, message: "UnLike failed")
                }
            }
        } else {
            Alamofire.request(HOST+"/items/\(articleID!)/like", method: .put, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":getAccessToken()]).response { (response) in
                if response.response?.statusCode == 204 {
                    self.like.image = UIImage(named: "Liked24pt")
                    self.isLiked = true
                    self.showDialog(title: "", message: "Liked")
                } else {
                    self.showDialog(title: FailTitle, message: "Like failed")
                }
            }
        }
    }
    
    @IBAction func categoryClick(_ sender: Any) {
        let realm = try! Realm()
        if realm.objects(Category.self).count == 0 {
            showDialog(title: "No categories found", message: "Add some categories on Category Tab")
            return
        }
        let alert = UIAlertController(title: "Add to category", message: "Choose category to add", preferredStyle: UIAlertController.Style.alert)
        for category in try! Realm().objects(Category.self) {
            alert.addAction(UIAlertAction(title: category.name, style: UIAlertAction.Style.default, handler: { (action) in
                let data = realm.objects(Category.self).filter("name == %@", category.name!).first
                let article = Articles()
                article.id = self.articleID
                article.title = self.articleTitle
                article.url = self.articleUrl
                article.image = self.articleImage
                article.user_id = self.user_id
                let saveData = Category()
                saveData.name = category.name
                data?.articles.forEach({ (article) in
                    saveData.articles.append(article)
                })
                saveData.articles.append(article)
                try! realm.write {
                    realm.add(saveData, update: true)
                }
                self.showDialog(title: "Success", message: "The article added to category")
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showDialog(title: String, message: String) {
        let dialog = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        self.present(dialog, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dialog.dismiss(animated: true, completion: {
                
            })
        }
    }
    
    func needToLogin(target: String) {
        let loginAlert = UIAlertController(title: "", message: "You need to login to Qiita to \(target) article.", preferredStyle: UIAlertController.Style.alert)
        loginAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        loginAlert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: { (action) in
            UIApplication.shared.open(URL(string: AuthorizeURI)!, options: [:]) { (result) in
                    if !result {
                        let alert = UIAlertController(title: "Can`t open browser", message: "Failed to open browser", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
            }
        }))
        self.present(loginAlert, animated: true, completion: nil)
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
