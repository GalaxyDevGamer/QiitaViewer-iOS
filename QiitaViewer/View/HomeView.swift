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

class HomeView: UIViewController, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var swipeRefresh = UIRefreshControl()
    
    let profile = UIButton(type: UIButton.ButtonType.custom)
    
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    
    let disposeBag = DisposeBag()
    
    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        indicator.center = self.view.center
        indicator.color = .gray
        self.view.addSubview(indicator)
        initNavigationBar()
        swipeRefresh.rx.controlEvent(UIControl.Event.valueChanged).asDriver().drive(onNext: { _ in
            self.viewModel.swipeRefresh().subscribe(onError: { (error) in
                self.endLoading()
                self.showError()
            }, onCompleted: {
                self.endLoading()
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        profile.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
            let view = UIStoryboard(name: "UserInfo", bundle: nil).instantiateViewController(withIdentifier: "UserInfoBoard") as! UserInfoView
            view.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(view, animated: true)
        }).disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name("updateProfileImage"), object: nil).subscribe({ (notification) in
            self.updateProfileImage()
        }).disposed(by: disposeBag)
        initTableView()
        initCollectionView()
        getArticle()
    }
    
    func initNavigationBar() {
        updateProfileImage()
        let left = UIBarButtonItem(customView: profile)
        left.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
        left.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        self.navigationItem.leftBarButtonItem = left
        let list = UIButton(type: UIButton.ButtonType.custom)
        list.setImage(UIImage(named: "List24pt"), for: UIControl.State.normal)
        list.rx.tap.asDriver().drive(onNext: { (_) in
            self.tableView.isHidden = false
            self.collectionView.isHidden = true
        }).disposed(by: disposeBag)
        let collection = UIButton(type: UIButton.ButtonType.custom)
        collection.setImage(UIImage(named: "CollectionMode24pt"), for: UIControl.State.normal)
        collection.rx.tap.asDriver().drive(onNext: { (_) in
            self.tableView.isHidden = true
            self.collectionView.isHidden = false
        }).disposed(by: disposeBag)
        let listItem = UIBarButtonItem(customView: list)
        listItem.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
        listItem.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        let collectionItem = UIBarButtonItem(customView: collection)
        collectionItem.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
        collectionItem.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        self.navigationItem.rightBarButtonItems = [listItem, collectionItem]
        self.navigationController?.navigationBar.barTintColor = UIColor.green
    }
    
    func initTableView() {
        self.tableView.addSubview(swipeRefresh)
        self.tableView.alwaysBounceVertical = true
        self.tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "Cell")
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfArticle>(configureCell: { (ds: TableViewSectionedDataSource<SectionOfArticle>, tableView: UITableView, indexPath: IndexPath, model: ArticleStruct) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ArticleCell
            cell.setData(thumbnail: model.user.profile_image_url, user_id: model.user.id, title: model.title, likes: model.likes)
            return cell
        })
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.articleProvider.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ArticleStruct.self)).bind { indexPath, article in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
            view.articleID = article.id
            view.articleTitle = article.title
            view.articleUrl = article.url
            view.articleImage = article.user.profile_image_url
            view.user_id = article.user.id
            self.present(view, animated: true, completion: nil)
            }.disposed(by: disposeBag)
        tableView.rx.contentOffset.subscribe { contentOffset in
            if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)-10)
            {   //一番下
                self.getArticle()
                //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
            }else{
                //一番下以外
                //@"(´・ω・`)");
            }
            }.disposed(by: disposeBag)
    }
    
    func initCollectionView() {
        collectionView.addSubview(swipeRefresh)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.register(UINib(nibName: "ArticleCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.rx.contentOffset.subscribe { contentOffset in
            if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height)-10)
            {   //一番下
                self.getArticle()
                //@"ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!");
            }else{
                //一番下以外
                //@"(´・ω・`)");
            }
            }.disposed(by: disposeBag)
        let collectionDataSource = RxCollectionViewSectionedReloadDataSource<SectionOfArticle>(configureCell: { (ds: CollectionViewSectionedDataSource<SectionOfArticle>, collectionView: UICollectionView, indexPath: IndexPath, model: ArticleStruct) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ArticleCollectionCell
            cell.setData(thumbnail: model.user.profile_image_url, userName: model.user.id, title: model.title, likes: model.likes)
            return cell
        })
        viewModel.articleProvider.bind(to: collectionView.rx.items(dataSource: collectionDataSource)).disposed(by: disposeBag)
        Observable.zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(ArticleStruct.self)).bind { indexPath, article in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
            view.articleID = article.id
            view.articleTitle = article.title
            view.articleUrl = article.url
            view.articleImage = article.user.profile_image_url
            view.user_id = article.user.id
            self.present(view, animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width/2-5, height: 200)
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
            self.getArticle()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getArticle() {
        indicator.startAnimating()
        viewModel.getArticle().subscribe(onError: { (error) in
            self.endLoading()
            self.showError()
            print("error")
        }) {
            self.endLoading()
            print("notify complete")
        }.disposed(by: disposeBag)
    }
    
    func endLoading() {
        self.swipeRefresh.endRefreshing()
        self.indicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
