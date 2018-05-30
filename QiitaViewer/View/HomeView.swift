//
//  ViewController.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/04/10.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class HomeView: UIViewController, UITableViewDelegate, UITableViewDataSource, URLSessionDelegate {
    @IBOutlet var tableView: UITableView!
    
    var page = 1
    var max = 0
    
    var items: [JSON] = []
    var images: [UIImage] = []
    
    var loading = false
    
    var swipeRefresh: UIRefreshControl!
    
    var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        indicator = UIActivityIndicatorView()
        indicator.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(indicator)
        swipeRefresh = UIRefreshControl()
        swipeRefresh.addTarget(self, action: #selector(onRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(swipeRefresh)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = true
        self.navigationItem.title = "Home"
        getArticle()
    }
    
    func getArticle() -> Void {
        indicator.startAnimating()
        loading = true
        page+=1
        max = 0
        //https://qiita.com/api/v2/items?per_page=%d&page=%d
        //let url = URL(string: "https://qiita.com/api/v2/items")
        let Authorization = ["Authorization": "Bearer 78a8efc0f8714dbb58b16dc51c4199d70b8d9cfe"]
        let params: Parameters = ["page":page]
        Alamofire.request("https://qiita.com/api/v2/items", method: .get, parameters: params, encoding: URLEncoding.default, headers:Authorization).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .success:
                let json = JSON(response.result.value ?? 0)
                json.forEach{ (_, data) in
                    self.items.append(data)
                    // Use Alamofire to download the image
                    Alamofire.request(data["user"]["profile_image_url"].string!).responseData { (response) in
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
                        if self.images.count == self.items.count {
                            self.tableView.reloadData()
                            self.max = self.items.count
                            self.loading = false
                            self.indicator.stopAnimating()
                        }
                    }
                }
            case .failure(let error):
                self.loading = false
                self.indicator.stopAnimating()
                print("error: %@", error)
            }
        })
        //        Alamofire.request(url!, method: .get, encoding: JSONEncoding.default).responseJSON{ response in
        //            switch response.result {
        //            case .success:
        //                let json:JSON = JSON(response.result.value ?? kill)
        //                print(json["title"])
        //                print(json["description"]["text"])
        //                if let objJson = response.result.value as! NSArray? {
        //                    self.articleArray.addObjects(from: objJson as! [Any])
        ////                    for element in objJson {
        ////                        let data = element as! NSDictionary
        ////                        if let arraySchedule = data["schedule"] as! NSArray? {
        ////                            for objSchedule in arraySchedule {
        ////                                self.arrSchedule.append(Schedule(jsonDic: objSchedule as! NSDictionary))
        ////                            }
        ////                        }
        ////                    }
        //                }
        //            case .failure(let error):
        //                print(error)
        //            }
        //        }
    }
    
    //    func getImage(array :[UIImage]) {
    //        var image: UIImage!
    //        Alamofire.request(url).responseData { response in
    //            switch response.result {
    //            case .success(_):
    //                image = UIImage(data: response.data!)
    //            case .failure(_):
    //                image = UIImage(named: "ic_image")
    //            }
    //        }
    //        return image
    //    }
    
    @objc func onRefresh(_ sender: Any) -> Void {
        if !loading{
            page = 0
            items.removeAll()
            images.removeAll()
            getArticle()
            swipeRefresh.endRefreshing()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)-10)
        {   //一番下
            if !loading {
                getArticle()
            }
            //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
        }else{
            //一番下以外
            //@"(´・ω・`)");
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewBoard") as! WebViewer
        view.articleID = items[indexPath.row]["id"].string
        view.articleTitle = items[indexPath.row]["title"].string
        view.articleBody = items[indexPath.row]["body"].string
        view.articleUrl = items[indexPath.row]["url"].string
        view.articleImage = items[indexPath.row]["user"]["profile_image_url"].string
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Article")!
        if max > 0 && items.count == max {
            cell.textLabel?.text = items[indexPath.row]["title"].string
        }
        if images.count != items.count {
            cell.imageView?.image = UIImage(named: "ic_image")
        } else if max > 0{
            cell.imageView?.image = images[indexPath.row]
        }
        // Use Alamofire to download the image
        //        Alamofire.request(items[indexPath.row]["user"]["profile_image_url"].string!).responseData { (response) in
        //            if response.error == nil {
        ////                print(response.result)
        //
        //                // Show the downloaded image:
        //                if let data = response.data {
        //                    cell.imageView?.image = UIImage(data: data)
        //                } else {
        //                    cell.imageView?.image = UIImage(named: "ic_image")
        //                }
        //            }
        //        }
        //        Alamofire.request("https://qiita.com/api/v2/items", method: .get, parameters: nil, encoding:URLEncoding.default, headers:Authorization).response(completionHandler: { (response, data) in
        //            switch response.result {
        //            case .success:
        //                cell.imageView?.image = UIImage(data: data)
        //            case .failure(let error):
        //                self.loading = false
        //                print("error: %@", error)
        //            }
        //        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
