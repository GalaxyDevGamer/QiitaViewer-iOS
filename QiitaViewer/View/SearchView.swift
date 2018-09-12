//
//  SearchView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/04/10.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class SearchView: UITableViewController, UISearchBarDelegate {
    
    var result: [JSON] = []
    var images: [UIImage] = []
    
    var loading = false
    var isSearched = false
    
    var swipeRefresh: UIRefreshControl!
    
    var page = 0
    
    var searchBar: UISearchBar!
    
    var history: Results<SearchHistory>!
    
    var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search Articles"
        searchBar.keyboardType = UIKeyboardType.default
        searchBar.barStyle = UIBarStyle.default
        searchBar.showsCancelButton = true
        self.navigationItem.titleView = searchBar
        self.tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
        loadHistory()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadHistory() {
        let realm = try! Realm()
        history = realm.objects(SearchHistory.self).sorted(byKeyPath: "date")
        tableView.reloadData()
    }
    
    func searchArticles(){
        indicator.startAnimating()
        page += 1
        loading = true
        let auth = ["Authorization": "Bearer "+UserDefaults.standard.string(forKey: "access_token")!]
        let params: Parameters = ["page": page, "query": searchBar.text as Any]
        Alamofire.request(HOST+API.Article.rawValue, method: .get, parameters: params, encoding: URLEncoding.default, headers: auth).validate().responseJSON(completionHandler: { response in
            if response.result.isSuccess {
                let json = JSON(response.result.value ?? 0)
                let group = DispatchGroup()
                json.forEach{(_, data) in
                    group.enter()
                    DispatchQueue(label: "loadData").async(group: group) {
                        Alamofire.request(data["user"]["profile_image_url"].string!).responseImage(completionHandler: { (response) in
                            if response.result.isSuccess {
                                self.images.append(response.value!)
                                print("image downloaded: \(self.images.count): \(self.result.count)")
                            } else {
                                self.images.append(UIImage(named: "ic_image")!)
                            }
                            self.result.append(data)
                            group.leave()
                        })
                    }
                }
                group.notify(queue: .main, execute: {
                    self.tableView.reloadData()
                    self.loading = false
                    self.indicator.stopAnimating()
                })
                self.isSearched = true
            } else {
                let alert = UIAlertController(title: "Error", message: "No result found", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.indicator.stopAnimating()
                self.loading = false
            }
        })
    }
    
    func addToHistory(){
        let realm = try! Realm()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        let date = Date()
        let history = SearchHistory()
        history.word = searchBar.text
        history.date = formatter.string(from: date)
        try! realm.write {
            realm.add(history, update: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        result.removeAll()
        page = 0
        searchArticles()
        addToHistory()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        result.removeAll()
        page = 0
        isSearched = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadHistory()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)-10)
        {   //一番下
            if !loading  && isSearched {
                searchArticles()
                print("loadmore")
            }
            //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
        }else{
            //一番下以外
            //@"(´・ω・`)");
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearched {
            let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
            view.articleID = result[indexPath.row]["id"].string
            view.articleTitle = result[indexPath.row]["title"].string
            view.articleUrl = result[indexPath.row]["url"].string
            view.articleBody = result[indexPath.row]["body"].string
            view.articleImage = result[indexPath.row]["user"]["profile_image_url"].string
            view.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(view, animated: true)
        } else {
            searchBar.text = history[indexPath.row].word
            searchArticles()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearched {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
            cell.setData(thumbnail: images[indexPath.row], user_id: result[indexPath.row]["user"]["id"].string!, title: result[indexPath.row]["title"].string!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Results", for: indexPath)
            cell.textLabel?.text = history[indexPath.row].word
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearched {
            return result.count
        } else {
            return history.count
        }
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
