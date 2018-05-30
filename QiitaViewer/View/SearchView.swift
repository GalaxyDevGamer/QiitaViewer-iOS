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

class SearchView: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var data: [JSON] = []
    var images: [UIImage] = []
    
    var loading = false
    var isSearched = false
    
    var swipeRefresh: UIRefreshControl!
    
    var page = 0
    var max = 0
    
    var searchBar: UISearchBar!
    
    var history: Results<SearchHistory>!
    
    var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = UIActivityIndicatorView()
        indicator.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(indicator)
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search Articles"
        searchBar.keyboardType = UIKeyboardType.default
        searchBar.barStyle = UIBarStyle.default
        searchBar.showsCancelButton = true
        self.navigationItem.titleView = searchBar
        tableView.delegate = self
        tableView.dataSource = self
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
        max = 0
        loading = true
        let auth = ["Authorization": "Bearer 78a8efc0f8714dbb58b16dc51c4199d70b8d9cfe"]
        let params: Parameters = ["page": page, "query": searchBar.text as Any]
        Alamofire.request("https://qiita.com/api/v2/items", method: .get, parameters: params, encoding: URLEncoding.default, headers: auth).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .success:
                let json = JSON(response.result.value ?? 0)
                json.forEach{(_, data) in
                    self.data.append(data)
                    Alamofire.request(data["user"]["profile_image_url"].string!).responseData { response in
                        switch response.result {
                        case .success(_):
                            if let image = UIImage(data: response.data!) {
                                self.images.append(image)
                            } else {
                                self.images.append(UIImage(named: "ic_image")!)
                            }
                        case .failure(_):
                            self.images.append(UIImage(named: "ic_image")!)
                        }
                        if self.images.count == data.count {
                            self.loading = false
                            self.isSearched = true
                            self.max = self.data.count
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                        }
                    }
                }
            case .failure(_):
                let alert = UIAlertController(title: "Error", message: "No result found", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
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
        data.removeAll()
        page = 0
        searchArticles()
        addToHistory()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        data.removeAll()
        page = 0
        isSearched = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadHistory()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearched {
            let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewBoard") as! WebViewer
            view.articleID = data[indexPath.row]["id"].string
            view.articleTitle = data[indexPath.row]["title"].string
            view.articleUrl = data[indexPath.row]["url"].string
            view.articleBody = data[indexPath.row]["body"].string
            view.articleImage = data[indexPath.row]["user"]["profile_image_url"].string
            view.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(view, animated: true)
        } else {
            searchBar.text = history[indexPath.row].word
            searchArticles()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Results", for: indexPath)
        //        Alamofire.request(data[indexPath.row]["user"]["profile_image_url"].string!, method: .get).responseImage(completionHandler: { response in
        //            guard let image: UIImage = response.result.value else {
        //                // Handle error
        //                cell.imageView?.image = UIImage(named: "ic_image")
        //                return
        //            }
        //            // Do stuff with your image
        //            cell.imageView?.image = image
        //        })
        if isSearched {
            cell.textLabel?.text = data[indexPath.row]["title"].string
        } else {
            cell.textLabel?.text = history[indexPath.row].word
        }
        if isSearched {
            if images.count != data.count {
                cell.imageView?.image = UIImage(named: "ic_image")
            } else if max > 0{
                cell.imageView?.image = images[indexPath.row]
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearched {
            return data.count
        } else {
            return history.count
        }
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
