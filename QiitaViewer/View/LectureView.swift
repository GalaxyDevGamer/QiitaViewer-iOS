//
//  LectureView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/01.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class LectureView: UITableViewController {

    var swipeRefresh: UIRefreshControl!
    var indicator: UIActivityIndicatorView!
    
    var page = 0
    var loading = false
    
    var article: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
        self.title = "Lecture"
        swipeRefresh = UIRefreshControl()
        swipeRefresh.addTarget(self, action: #selector(onRefresh(_:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(swipeRefresh)
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.center = self.view.center
        getLectures()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return article.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell

        // Configure the cell...
        cell.title.text = article[indexPath.row]["title"].string
        cell.user.text = article[indexPath.row]["user"]["id"].string
        Alamofire.request(article[indexPath.row]["user"]["profile_image_url"].string!).responseImage { (response) in
            if response.result.isSuccess {
                cell.thumbnail.image = response.value
            } else {
                cell.thumbnail.image = UIImage(named: "ic_image")
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
        view.articleID = article[indexPath.row]["id"].string
        view.articleTitle = article[indexPath.row]["title"].string
        view.articleUrl = article[indexPath.row]["url"].string
        view.articleImage = article[indexPath.row]["user"]["profile_image_url"].string
        view.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(view, animated: true)
    }

    @objc func onRefresh(_ sender: Any) {
        if loading == false {
            article.removeAll()
            getLectures()
        }
    }
    
    func getLectures() {
        indicator.startAnimating()
        loading = true
        page+=1
        Alamofire.request(HOST+API.Lectures.rawValue, method: .get, parameters: ["page":page], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.value as Any)
                json.forEach({ (str, data) in
                    self.article.append(data)
                })
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Error", message: "Failed to get lectures", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.indicator.stopAnimating()
            self.loading = false
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
