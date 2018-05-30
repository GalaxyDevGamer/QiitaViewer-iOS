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

class StockView: UITableViewController {

    var stocks: [JSON] = []
    var images: [UIImage] = []
    
    var loading = false
    
    var page = 0
    var max = 0
    
    var swipeRefresh: UIRefreshControl!
    
    var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.title = "Stocks"
        swipeRefresh = UIRefreshControl()
        swipeRefresh.addTarget(self, action: #selector(onRefresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(swipeRefresh)
        self.tableView.alwaysBounceVertical = true
        indicator = UIActivityIndicatorView()
        indicator.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(indicator)
        getStocks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onRefresh(_ sender: Any) -> Void {
        page = 0
        stocks.removeAll()
        images.removeAll()
        getStocks()
        swipeRefresh.endRefreshing()
    }
    
    func getStocks(){
        indicator.startAnimating()
        loading = true
        page+=1
        max = 0
        let params = ["page":page]
        Alamofire.request("https://qiita.com/api/v2/users/Galaxy/stocks", method: .get, parameters: params, encoding: URLEncoding.default, headers:nil).validate().responseJSON(completionHandler: { response in
            print(response.result)
            switch response.result {
            case .success:
                let json = JSON(response.result.value ?? 0)
                json.forEach{ (_, data) in
                    self.stocks.append(data)
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
                        if self.images.count == self.stocks.count {
                            self.loading = false
                            self.max = self.stocks.count
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                        }
                    }
                }
                print(self.images.count)
            case .failure(let error):
                print("error: %@", error)
                let alert = UIAlertController(title: "Error", message: "Failed to load stock data", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.indicator.stopAnimating()
            }
        })
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stocks.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewBoard") as! WebViewer
        view.articleID = stocks[indexPath.row]["id"].string
        view.articleTitle = stocks[indexPath.row]["title"].string
        view.articleUrl = stocks[indexPath.row]["url"].string
        view.articleImage = stocks[indexPath.row]["user"]["profile_image_url"].string
        view.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(view, animated: true)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stocks", for: indexPath)
        // Configure the cell...
        if max > 0 && stocks.count == max {
            cell.textLabel?.text = stocks[indexPath.row]["title"].string
        }
        if images.count != stocks.count {
            cell.imageView?.image = UIImage(named: "ic_image")
        } else if max > 0{
            cell.imageView?.image = images[indexPath.row]
        }
        return cell
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
