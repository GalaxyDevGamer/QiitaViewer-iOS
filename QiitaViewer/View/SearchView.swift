//
//  SearchView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/04/10.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxDataSources

class SearchView: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = SearchViewModel()
    
    var searchBar = UISearchBar()
    
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        indicator.center = self.view.center
        indicator.color = .gray
        self.view.addSubview(indicator)
        searchBar.placeholder = "Search Articles"
        searchBar.barStyle = UIBarStyle.default
        searchBar.showsCancelButton = true
        self.navigationItem.titleView = searchBar
        self.tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfArticle>(configureCell: { (ds: TableViewSectionedDataSource<SectionOfArticle>, tableView: UITableView, indexPath: IndexPath, model: ArticleStruct) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
            cell.setData(thumbnail: model.user.profile_image_url, user_id: model.user.id, title: model.title, likes: model.likes)
            return cell
        })
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.resultProvider.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ArticleStruct.self)).bind { indexPath, result in
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.present(ViewProvider.get.browser(article: result), animated: true, completion: nil)
            }.disposed(by: disposeBag)
        tableView.rx.contentOffset.subscribe { scrollView in
            if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)-10)
            {   //一番下
                if self.viewModel.results.count > 0 {
                    self.indicator.startAnimating()
                    self.viewModel.loadMore().subscribe(onNext: { (data) in
                        
                    }, onError: { (error) in
                        self.indicator.stopAnimating()
                        self.showError()
                    }, onCompleted: {
                        self.indicator.stopAnimating()
                    }).disposed(by: self.disposeBag)
                }
                //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
            }else{
                //一番下以外
                //@"(´・ω・`)");
            }
        }.disposed(by: disposeBag)
        searchBar.rx.searchButtonClicked.subscribe { bar in
            self.searchBar.resignFirstResponder()
            self.searchArticles()
            self.viewModel.addToHistory(text: self.searchBar.text!)
        }.disposed(by: disposeBag)
        searchBar.rx.cancelButtonClicked.subscribe { bar in
            self.viewModel.clearResult()
            self.searchBar.resignFirstResponder()
            self.searchBar.text = ""
            self.viewModel.loadHistory()

        }.disposed(by: disposeBag)
        self.navigationController?.navigationBar.barTintColor = UIColor.green
        viewModel.loadHistory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if viewModel.results.count == 0 {
            searchBar.text = viewModel.history[indexPath.row].word
            searchArticles()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.results.count > 0 {
            return viewModel.results.count
        } else {
            return viewModel.history.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func showError() {
        let alert = UIAlertController(title: "Error", message: "Failed to search articles."+plsCheckInternet, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { (action) in
            self.searchArticles()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func searchArticles() {
        indicator.startAnimating()
        viewModel.searchArticles(query: self.searchBar.text!).subscribe(onNext: { (data) in
            
        }, onError: { (error) in
            self.indicator.stopAnimating()
            self.showError()
        }, onCompleted: {
            self.indicator.stopAnimating()
        }).disposed(by: disposeBag)
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
