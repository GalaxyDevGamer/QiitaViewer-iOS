//
//  UserInfoView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/08/31.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserInfoView: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var user_id: UILabel!
    @IBOutlet weak var user_description: UITextView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    let viewModel = UserInfoViewModel()
    
    let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        indicator.center = self.view.center
        indicator.color = .gray
        self.view.addSubview(indicator)
        TokenObserver.shared.authorizeState.asDriver().drive(loginView.rx.isHidden).disposed(by: disposeBag)
        TokenObserver.shared.authorizeStateObserver().subscribe(onNext: { (state) in
            if state {
                self.loadUserInfoView()
            } else {
                self.loadLoginView()
            }
        }).disposed(by: disposeBag)
        viewModel.errorNotifier.subscribe(onNext: { (message) in
            self.showError(title: "Failed", message: message)
        }).disposed(by: disposeBag)
        viewModel.showLoading.subscribe(onNext: { (isLoading) in
            if isLoading {
                self.indicator.startAnimating()
            } else {
                self.indicator.stopAnimating()
            }
        }).disposed(by: disposeBag)
        self.navigationController?.navigationBar.tintColor = UIColor.green
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.image = UIImage(named: "Back24pt")
    }
    
    func loadLoginView() {
        self.title = "Login to Qiita"
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "OAuth Result"), object: nil).subscribe(onNext: { (notification) in
            self.oauthResult()
        }).disposed(by: self.disposeBag)
        loginButton.rx.tap.asDriver().drive(onNext: {
            self.viewModel.login()
        }).disposed(by: disposeBag)
    }
    
    func loadUserInfoView() {
        self.title = "UserInfo"
        viewModel.user_id.bind(to: user_id.rx.text).disposed(by: disposeBag)
        viewModel.description.bind(to: user_description.rx.text).disposed(by: disposeBag)
        viewModel.profile_image.bind(to: thumbnail.rx.image).disposed(by: disposeBag)
        self.logoutButton.rx.tap.asDriver().drive(onNext: {
            self.viewModel.logout()
        }).disposed(by: disposeBag)
        viewModel.loginAlert.subscribe(onNext: { (error) in
            let loginAlert = UIAlertController(title: "Connection Failed", message: "Unable to get UserInfo. Please check your internet connection or Login again.", preferredStyle: UIAlertController.Style.alert)
            loginAlert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { action in
                self.loadUserInfoView()
            }))
            loginAlert.addAction(UIAlertAction(title: "Login again", style: UIAlertAction.Style.default, handler: { (action) in
                self.viewModel.login()
            }))
            self.present(loginAlert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        viewModel.getUserInfo()
    }
    
    func oauthResult() {
        if UserDefaults.standard.string(forKey: "access_token") == nil {
            showError(title: "", message: "Login Failed. Please check your internet connection and try again.")
        } else {
            showError(title: "", message: "Login Success")
        }
    }
    
    func showError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
