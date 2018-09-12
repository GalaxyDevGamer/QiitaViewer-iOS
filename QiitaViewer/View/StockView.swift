//
//  StockView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/05/23.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StockView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var stocks: [JSON] = []
    var images: [UIImage] = []
    
    var loading = false
    
    var page = 0
    
    var swipeRefresh: UIRefreshControl!
    
    var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noStockView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.title = "Stocks"
        swipeRefresh = UIRefreshControl()
        swipeRefresh.addTarget(self, action: #selector(onRefresh(_:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(swipeRefresh)
        self.tableView.alwaysBounceVertical = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        self.tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatus), name: NSNotification.Name("UpdateStocks"), object: nil)
        updateStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateStatus() {
        if UserDefaults.standard.string(forKey: "access_token") == nil {
            stocks.removeAll()
            images.removeAll()
            self.tableView.reloadData()
            noStockView.isHidden = false
            self.tableView.isHidden = true
        } else {
            noStockView.isHidden = true
            self.tableView.isHidden = false
            getStocks()
        }
    }
    
    @objc func onRefresh(_ sender: Any) {
        if !loading {
            page = 0
            stocks.removeAll()
            getStocks()
            swipeRefresh.endRefreshing()
        }
    }
    
    func getStocks(){
        if UserDefaults.standard.string(forKey: "id") == nil {
            return
        }
        indicator.startAnimating()
        loading = true
        page+=1
        let params = ["page":page]
        Alamofire.request(HOST+"/users/\(UserDefaults.standard.string(forKey: "id")!)/stocks", method: .get, parameters: params, encoding: URLEncoding.default, headers:nil).validate().responseJSON(completionHandler: { response in
            if response.result.isSuccess {
                let json = JSON(response.value ?? 0)
                let group = DispatchGroup()
                json.forEach{ (_, data) in
                    group.enter()
                    print("enter")
                    DispatchQueue(label: "loadCell").async(group: group) {
                        Alamofire.request(data["user"]["profile_image_url"].string!).responseImage(completionHandler: { (response) in
                            if response.result.isSuccess {
                                self.images.append(response.value!)
                                print("image downloaded: \(self.images.count): \(self.stocks.count)")
                            } else {
                                self.images.append(UIImage(named: "ic_image")!)
                            }
                            self.stocks.append(data)
                            group.leave()
                            print("leave")
                        })
                    }
                }
                group.notify(queue: .main, execute: {
                    self.tableView.reloadData()
                    if self.stocks.count == 0 {
                        self.noStockView.isHidden = false
                    } else {
                        self.noStockView.isHidden = true
                    }
                    self.loading = false
                    self.indicator.stopAnimating()
                    print("items: \(self.stocks.count), images: \(self.images.count)")
                })
            } else {
                let alert = UIAlertController(title: "Error", message: "Failed to load stock data", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.loading = false
                self.indicator.stopAnimating()
            }
        })
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stocks.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
        view.articleID = stocks[indexPath.row]["id"].string
        view.articleTitle = stocks[indexPath.row]["title"].string
        view.articleUrl = stocks[indexPath.row]["url"].string
        view.articleImage = stocks[indexPath.row]["user"]["profile_image_url"].string
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
        cell.setData(thumbnail: images[indexPath.row], user_id: stocks[indexPath.row]["user"]["id"].string!, title: stocks[indexPath.row]["title"].string!)
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)-10)
        {   //一番下
            if !loading {
                getStocks()
            }
            //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
        }else{
            //一番下以外
            //@"(´・ω・`)");
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
