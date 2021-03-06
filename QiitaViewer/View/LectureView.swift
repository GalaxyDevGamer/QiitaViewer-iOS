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
            self.viewModel.swipeRefresh().subscribe(onNext: { (data) in
                
            }, onError: { (error) in
                self.endRefreshing()
                self.showError()
            }, onCompleted: {
                self.endRefreshing()
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        self.tableView.addSubview(swipeRefresh)
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfArticle>(configureCell: { (ds: TableViewSectionedDataSource<SectionOfArticle>, tableView: UITableView, indexPath: IndexPath, model: ArticleStruct) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
            cell.setData(thumbnail: model.user.profile_image_url, user_id: model.user.id, title: model.title, likes: 0)
            return cell
        })
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.lectureProvider.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ArticleStruct.self)).bind { indexPath, lecture in
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.present(ViewProvider.get.browser(article: lecture), animated: true, completion: nil)
        }.disposed(by: disposeBag)
        tableView.rx.contentOffset.subscribe { scrollView in
            if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)-10)
            {   //一番下
                self.getLectures()
                //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
            }else{
                //一番下以外
                //@"(´・ω・`)");
            }
        }.disposed(by: disposeBag)
        self.navigationController?.navigationBar.barTintColor = UIColor.green
        getLectures()
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
            self.getLectures()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getLectures() {
        indicator.startAnimating()
        self.viewModel.getLectures().subscribe(onNext: { (data) in
            
        }, onError: { (error) in
            self.endRefreshing()
            self.showError()
        }, onCompleted: {
            self.endRefreshing()
        }).disposed(by: disposeBag)
    }
    
    func endRefreshing() {
        self.indicator.stopAnimating()
        self.swipeRefresh.endRefreshing()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
