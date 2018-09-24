//
//  FavouriteView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/04/10.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class TagArticleView: UIViewController, UITableViewDelegate {
    
    var name: String!
    
    let disposeBag = DisposeBag()
    
    let viewModel = TagArticleViewModel()
    
    var dataSource: RxTableViewSectionedAnimatedDataSource<SectionOfTagArticle>!
    
    @IBOutlet weak var noArticleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = name
        viewModel.name = name
        tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
        viewModel.isArticleAvailable.bind(to: noArticleView.rx.isHidden).disposed(by: disposeBag)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfTagArticle>.init(configureCell: { (ds: TableViewSectionedDataSource<SectionOfTagArticle>, tableView: UITableView, indexPath: IndexPath, model: TagArticleStruct) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
            cell.setData(thumbnail: model.profile_image_url, user_id: model.user_id, title: model.title, likes: 0)
            return cell
        })
        dataSource.canEditRowAtIndexPath = {_,_  in true}
        viewModel.articleNotifier.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(TagArticleStruct.self)).bind { indexPath, article in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
            view.articleID = article.id
            view.articleTitle = article.title
            view.articleUrl = article.url
            view.articleImage = article.profile_image_url
            view.user_id = article.user_id
            view.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(view, animated: true)
            }.disposed(by: disposeBag)
        tableView.rx.itemDeleted.subscribe (onNext: { indexPath in
            self.viewModel.removeArticle(index: indexPath.row)
        }).disposed(by: disposeBag)
        self.navigationController?.navigationBar.barTintColor = UIColor.green
        viewModel.loadArticles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
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
