//
//  LectureView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/01.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class LectureView: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = LectureViewModel()
    
    var swipeRefresh = UIRefreshControl()
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "Lectures"
        indicator.center = self.view.center
        indicator.color = .gray
        self.tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
        swipeRefresh.rx.controlEvent(UIControl.Event.valueChanged).subscribe({_ in
            self.viewModel.swipeRefresh()
        }).disposed(by: disposeBag)
        self.tableView.addSubview(swipeRefresh)
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfArticle>(configureCell: { (ds: TableViewSectionedDataSource<SectionOfArticle>, tableView: UITableView, indexPath: IndexPath, model: ArticleStruct) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
            cell.setData(thumbnail: model.user.profile_image_url, user_id: model.user.id, title: model.title, likes: 0)
            return cell
        })
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.lectureNotifier.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ArticleStruct.self)).bind { indexPath, lecture in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
            view.articleID = lecture.id
            view.articleTitle = lecture.title
            view.articleUrl = lecture.url
            view.articleImage = lecture.user.profile_image_url
            view.user_id = lecture.user.id
            self.present(view, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        tableView.rx.contentOffset.subscribe { scrollView in
            if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)-10)
            {   //一番下
                self.viewModel.getLectures()
                //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
            }else{
                //一番下以外
                //@"(´・ω・`)");
            }
        }.disposed(by: disposeBag)
        viewModel.showLoading.subscribe(onNext: { (showLoading) in
            if showLoading {
                self.indicator.startAnimating()
            } else {
                self.indicator.stopAnimating()
            }
        }).disposed(by: disposeBag)
        viewModel.refreshing.subscribe(onNext: { (isRefreshing) in
            self.swipeRefresh.endRefreshing()
        }).disposed(by: disposeBag)
        viewModel.errorNotifier.subscribe(onNext: { (error) in
            self.showError()
        }).disposed(by: disposeBag)
        self.navigationController?.navigationBar.barTintColor = UIColor.green
        viewModel.getLectures()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.lectures.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func showError() {
        let alert = UIAlertController(title: "Error", message: "Failed to get lectures."+plsCheckInternet, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { (action) in
            self.viewModel.getLectures()
        }))
        self.present(alert, animated: true, completion: nil)
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
