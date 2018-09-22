//
//  WebViewer.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/04/10.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RealmSwift
import WebKit
import RxSwift
import RxCocoa

class BrowserView: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var articleID: String?
    var articleTitle: String?
    var articleBody: String?
    var articleUrl: String?
    var articleImage: String?
    var user_id: String!
    
    let disposeBag = DisposeBag()
    
    let viewModel = BrowserViewModel()
    
    let stock = UIButton(type: UIButton.ButtonType.custom)
    let like = UIButton(type: UIButton.ButtonType.custom)
    let tag = UIButton(type: UIButton.ButtonType.custom)
    
    @IBOutlet var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        viewModel.articleID = articleID
        if UserDefaults.standard.string(forKey: "id") == nil {
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "loginSuccess"), object: nil).subscribe(onNext: { (notification) in
                self.showDialog(title: "", message: "Login Success")
            }).disposed(by: disposeBag)
        }
        viewModel.stockImage.bind(to: stock.rx.image(for: UIControl.State.normal)).disposed(by: disposeBag)
        viewModel.likeImage.bind(to: like.rx.image(for: UIControl.State.normal)).disposed(by: disposeBag)
        viewModel.tagImage.bind(to: tag.rx.image(for: UIControl.State.normal)).disposed(by: disposeBag)
        stock.rx.tap.asDriver().drive(onNext: { _ in
            self.viewModel.stockClick()
        }).disposed(by: disposeBag)
        like.rx.tap.asDriver().drive(onNext: { _ in
            self.viewModel.likeClick()
        }).disposed(by: disposeBag)
        tag.rx.tap.asDriver().drive(onNext: { _ in
            self.tagClick()
        }).disposed(by: disposeBag)
        viewModel.loginAlert.subscribe(onNext: { (target) in
            self.needToLogin(target: target)
        }).disposed(by: disposeBag)
        viewModel.resultNotify.subscribe(onNext: { (message) in
            self.showDialog(title: "", message: message)
        }).disposed(by: disposeBag)
        let stockItem = UIBarButtonItem(customView: stock)
        stockItem.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
        stockItem.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        let likeItem = UIBarButtonItem(customView: like)
        likeItem.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
        likeItem.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        let tagItem = UIBarButtonItem(customView: tag)
        tagItem.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
        tagItem.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        navigationItem.rightBarButtonItems = [stockItem, likeItem, tagItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        webView.load(URLRequest(url: URL(string: articleUrl!)!))
        //        webView.load(URLRequest(url: URL(string: articleUrl!+"?access_token"+UserDefaults.standard.string(forKey: "access_token")!)!))
        self.navigationItem.title = articleTitle
        self.navigationController?.navigationBar.barTintColor = UIColor.green
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.image = UIImage(named: "Back24pt")
        viewModel.checkStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tagClick() {
        if viewModel.tags.count == 0 {
            showDialog(title: "No tags found", message: "Add some tags on Tag Tab")
            return
        }
        let alert = UIAlertController(title: "Add to tag", message: "Choose tag to add", preferredStyle: UIAlertController.Style.actionSheet)
        for tag in viewModel.tags {
            alert.addAction(UIAlertAction(title: tag.name, style: UIAlertAction.Style.default, handler: { (action) in
                self.viewModel.addToTag(name: tag.name!, title: self.articleTitle!, url: self.articleUrl!, image: self.articleImage!, user_id: self.user_id)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDialog(title: String, message: String) {
        let dialog = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        self.present(dialog, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dialog.dismiss(animated: true, completion: {
                
            })
        }
    }
    
    func needToLogin(target: String) {
        let loginAlert = UIAlertController(title: "", message: "You need to login to Qiita to \(target) article.", preferredStyle: UIAlertController.Style.alert)
        loginAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        loginAlert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: { (action) in
            UIApplication.shared.open(URL(string: AuthorizeURI)!, options: [:]) { (result) in
                if !result {
                    let alert = UIAlertController(title: "Can`t open browser", message: "Failed to open browser", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }))
        self.present(loginAlert, animated: true, completion: nil)
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
