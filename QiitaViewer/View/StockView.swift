//
//  StockView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/05/23.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class StockView: UIViewController, UITableViewDelegate {
    
    let viewModel = StockViewModel()
    
    var swipeRefresh = UIRefreshControl()
    
    let disposeBag = DisposeBag()
    
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noStockView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        initUI()
        swipeRefresh.rx.controlEvent(UIControl.Event.valueChanged).subscribe(onNext: { _ in
            self.viewModel.swipeRefresh().subscribe(onError: { (error) in
                self.endRefreshing()
                self.showError()
            }, onCompleted: {
                self.endRefreshing()
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        TokenObserver.shared.authorizeState.asDriver().drive(noStockView.rx.isHidden).disposed(by: disposeBag)
        StockRequest.shared.isStockAvailable.asDriver().drive(noStockView.rx.isHidden).disposed(by: disposeBag)
        TokenObserver.shared.authorizeStateObserver().subscribe(onNext: { (status) in
            if status {
                self.getStocks()
            } else {
                self.viewModel.stocks.removeAll()
                self.viewModel.page = 0
            }
        }).disposed(by: disposeBag)
        self.navigationController?.navigationBar.barTintColor = UIColor.green
    }
    
    func initUI() {
        indicator.center = self.view.center
        indicator.color = .gray
        self.view.addSubview(indicator)
        self.tableView.addSubview(swipeRefresh)
        self.tableView.alwaysBounceVertical = true
        self.tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfArticle>(configureCell: { (ds: TableViewSectionedDataSource<SectionOfArticle>, tableView: UITableView, indexPath: IndexPath, model: ArticleStruct) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
            cell.setData(thumbnail: model.user.profile_image_url, user_id: model.user.id, title: model.title, likes: model.likes)
            return cell
        })
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.stockNotify.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ArticleStruct.self)).bind { indexPath, stock in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
            view.articleID = stock.id
            view.articleTitle = stock.title
            view.articleUrl = stock.url
            view.articleImage = stock.user.profile_image_url
            view.user_id = stock.user.id
            self.present(view, animated: true, completion: nil)
            }.disposed(by: disposeBag)
        tableView.rx.contentOffset.subscribe { scrollView in
            if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)-10)
            {   //一番下
                if TokenObserver.shared.authorizeState.value {
                    self.getStocks()
                }
                //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
            }else{
                //一番下以外
                //@"(´・ω・`)");
            }
            }.disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.stocks.count
    }
    
    func showError() {
        let alert = UIAlertController(title: "Error", message: "Failed to load stocks."+plsCheckInternet, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { (action) in
            self.getStocks()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getStocks() {
        indicator.startAnimating()
        viewModel.getStocks().subscribe(onError: { (error) in
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
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
