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
import ObjectMapper
import AlamofireObjectMapper
import RxSwift

class HomeView: UITableViewController, URLSessionDelegate {
    
    var page = 0
    var size = 0
    
    var images: [UIImage] = []
    var articles: [Article] = []
    
    var loading = false
    var isSwipeRefresh = false
    
    var swipeRefresh: UIRefreshControl!
    
    var indicator: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.center = self.view.center
        indicator.color = .gray
        self.view.addSubview(indicator)
        swipeRefresh = UIRefreshControl()
        swipeRefresh.addTarget(self, action: #selector(onRefresh(_:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(swipeRefresh)
        self.tableView.alwaysBounceVertical = true
        self.navigationItem.title = "Home"
        self.tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
        updateProfileImage()
        getArticle()
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileImage), name: NSNotification.Name(rawValue: "updateProfileImage"), object: nil)
    }
    
    func getArticle() -> Void {
        if loading {
            return
        }
        indicator.startAnimating()
        loading = true
        page+=1
        //https://qiita.com/api/v2/items?per_page=%d&page=%d
        var authorization = ["Authorization": "Bearer "]
        if UserDefaults.standard.string(forKey: "access_token") != nil {
            authorization = ["Authorization": "Bearer "+UserDefaults.standard.string(forKey: "access_token")!]
        }
        ArticleRequest.shaeredInstance.request(page: page).subscribe(onNext: { (articles) in
            let group = DispatchGroup()
            for article in articles {
                group.enter()
                DispatchQueue(label: "getData").async(group: group) {
                    ArticleRequest.shaeredInstance.downloadImage(url: (article.user?.profile_image_url)!).subscribe(onNext: { (image) in
                        ArticleManager.sharedInstance.images.append(image)
                    }, onError: { (error) in
                        ArticleManager.sharedInstance.images.append(UIImage(named: "ic_image")!)
                    }, onCompleted: {
                    }, onDisposed: {
                        ArticleManager.sharedInstance.articles.append(article)
                        group.leave()
                    }).disposed(by: self.disposeBag)
                }
            }
            group.notify(queue: .main, execute: {
                self.tableView.reloadData()
                self.hideLoading()
            })
        }, onError: { (error) in
            let alert = UIAlertController(title: "Error", message: "Failed to get articles", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.hideLoading()
        }, onCompleted: {
            
        }) {

        }.disposed(by: disposeBag)
    }
    
    @objc func onRefresh(_ sender: Any) -> Void {
        if !loading{
            page = 0
            size = 0
            isSwipeRefresh = true
            getArticle()
            swipeRefresh.endRefreshing()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)-10)
        {   //一番下
            if loading == false {
                print("scroll \(self.loading)")
                getArticle()
                print("load more")
            }
            //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
        }else{
            //一番下以外
            //@"(´・ω・`)");
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
        view.articleID = ArticleManager.sharedInstance.articles[indexPath.row].id
        view.articleTitle = ArticleManager.sharedInstance.articles[indexPath.row].title
        view.articleUrl = ArticleManager.sharedInstance.articles[indexPath.row].url
        view.articleImage = ArticleManager.sharedInstance.articles[indexPath.row].user?.profile_image_url
        view.user_id = ArticleManager.sharedInstance.articles[indexPath.row].user?.id
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ArticleCell
        cell.setData(thumbnail: ArticleManager.sharedInstance.images[indexPath.row], user_id: (ArticleManager.sharedInstance.articles[indexPath.row].user?.id)!, title: ArticleManager.sharedInstance.articles[indexPath.row].title!)
        size+=1
        print("attached to cell: \(self.size)")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticleManager.sharedInstance.articles.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @objc func userClick(_ sender: Any) {
        let view = UIStoryboard(name: "UserInfo", bundle: nil).instantiateViewController(withIdentifier: "UserInfoBoard") as! UserInfoView
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    
    @objc func updateProfileImage() {
        if UserDefaults.standard.string(forKey: "profile_image") == nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "User24pt"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(userClick(_:)))
        } else {
            Alamofire.request(UserDefaults.standard.string(forKey: "profile_image")!).responseImage(completionHandler: { (response) in
                if response.result.isSuccess {
                    let button = UIButton(type: .custom)
                    button.setImage(UIImage(data: response.data!, scale: 3.0)?.withRenderingMode(.alwaysOriginal), for: .normal)
                    button.addTarget(self, action: #selector(self.userClick(_:)), for: UIControl.Event.touchUpInside)
                    let left = UIBarButtonItem(customView: button)
                    left.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
                    left.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
                    self.navigationItem.leftBarButtonItem = left
                    //                self.navigationItem.rightBarButtonItem = left
                    //                self.profile_image.image = UIImage(data: response.data!, scale: 10.0)?.withRenderingMode(.alwaysOriginal)
                    
                }
            })
        }
    }
    
    func hideLoading() {
        self.loading = false
        self.indicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
