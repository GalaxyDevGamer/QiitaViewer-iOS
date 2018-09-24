//
//  ViewController.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/04/10.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift
import RxDataSources

class HomeView: UIViewController, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var swipeRefresh = UIRefreshControl()
    
    let profile = UIButton(type: UIButton.ButtonType.custom)
    
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    
    let disposeBag = DisposeBag()
    
    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initUI()
        swipeRefresh.rx.controlEvent(UIControl.Event.valueChanged).asDriver().drive(onNext: { _ in
            self.viewModel.swipeRefresh()
        }).disposed(by: disposeBag)
        profile.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
            let view = UIStoryboard(name: "UserInfo", bundle: nil).instantiateViewController(withIdentifier: "UserInfoBoard") as! UserInfoView
            view.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(view, animated: true)
        }).disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name("updateProfileImage"), object: nil).subscribe({ (notification) in
            self.updateProfileImage()
        }).disposed(by: disposeBag)
        viewModel.showLoading.subscribe(onNext: { (isLoading) in
            if isLoading {
                self.indicator.startAnimating()
            } else {
                self.indicator.stopAnimating()
            }
        }).disposed(by: disposeBag)
        viewModel.endRefreshing.subscribe { _ in
            self.swipeRefresh.endRefreshing()
            }.disposed(by: disposeBag)
        viewModel.notifyError.subscribe { (error) in
            self.showError()
            }.disposed(by: disposeBag)
        viewModel.getArticle()
    }
    
    func initUI() {
        indicator.center = self.view.center
        indicator.color = .gray
        self.view.addSubview(indicator)
        self.tableView.addSubview(swipeRefresh)
        self.tableView.alwaysBounceVertical = true
        self.tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfArticle>(configureCell: { (ds: TableViewSectionedDataSource<SectionOfArticle>, tableView: UITableView, indexPath: IndexPath, model: ArticleStruct) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
            cell.setData(thumbnail: model.user.profile_image_url, user_id: model.user.id, title: model.title, likes: model.likes)
            return cell
        })
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.articleNotify.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ArticleStruct.self)).bind { indexPath, article in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
            view.articleID = article.id
            view.articleTitle = article.title
            view.articleUrl = article.url
            view.articleImage = article.user.profile_image_url
            view.user_id = article.user.id
            view.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(view, animated: true)
            }.disposed(by: disposeBag)
        tableView.rx.contentOffset.subscribe { contentOffset in
            if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)-10)
            {   //一番下
                self.viewModel.getArticle()
                //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
            }else{
                //一番下以外
                //@"(´・ω・`)");
            }
            }.disposed(by: disposeBag)
        updateProfileImage()
        let left = UIBarButtonItem(customView: profile)
        left.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
        left.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        self.navigationItem.leftBarButtonItem = left
        self.navigationController?.navigationBar.barTintColor = UIColor.green
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func updateProfileImage() {
        if UserDefaults.standard.string(forKey: "profile_image") == nil {
            profile.setImage(UIImage(named: "User24pt"), for: .normal)
        } else {
            profile.af_setImage(for: ControlState.normal, url: URL(string: UserDefaults.standard.string(forKey: "profile_image")!)!)
        }
    }
    
    func showError() {
        let alert = UIAlertController(title: "Error", message: "Failed to get articles."+plsCheckInternet, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { (action) in
            self.viewModel.getArticle()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
