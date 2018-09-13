//
//  UserInfoView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/08/31.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RxSwift

class UserInfoView: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var user_id: UILabel!
    @IBOutlet weak var user_description: UITextView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userInfoView: UIView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserInfoView), name: NSNotification.Name("showUserInfo"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: "access_token") == nil {
            loginView.isHidden = false
            self.title = "Login to Qiita"
        } else {
            loadUserInfoView()
        }
    }
    
    @objc func loadUserInfoView() {
        loginView.isHidden = true
        userInfoView.isHidden = false
        self.title = "UserInfo"
        UserInfoRequest.sharedInstance.getUserInfo().subscribe(onNext: { (userInfo) in
            UserInfoRequest.sharedInstance.getProfileImage(url: userInfo.profile_image_url!).subscribe(onNext: { (image) in
                self.thumbnail.image = image
                self.user_id.text = userInfo.id
                self.user_description.text = userInfo.description
                UserDefaults.standard.set(userInfo.id, forKey: "id")
                UserDefaults.standard.set(userInfo.profile_image_url, forKey: "profile_image")
            }, onError: { (error) in
                self.thumbnail.image = UIImage(named: "User48pt")
            }, onCompleted: {
                
            }, onDisposed: {
                
            }).disposed(by: self.disposeBag)
        }, onError: { (error) in
            let loginAlert = UIAlertController(title: "Connection Failed", message: "Unable to get UserInfo", preferredStyle: UIAlertController.Style.alert)
            loginAlert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { action in
                self.loadUserInfoView()
            }))
            loginAlert.addAction(UIAlertAction(title: "Login again", style: UIAlertAction.Style.default, handler: { (action) in
                self.openBrowser()
            }))
            self.present(loginAlert, animated: true, completion: nil)
        }, onCompleted: {
            
        }) {
            
        }.disposed(by: disposeBag)
    }
    
    @IBAction func loginClick(_ sender: Any) {
        openBrowser()
    }
    
    func openBrowser() {
        UIApplication.shared.open(URL(string: AuthorizeURI)!, options: [:]) { result in
            if result == false {
                self.showError(title: "", message: "Failed to open browser")
            }
        }
    }
    
    @IBAction func logoutClick(_ sender: Any) {
        UserInfoRequest.sharedInstance.logout().subscribe(onNext: { (isSuccess) in
            UserDefaults.standard.removeObject(forKey: "access_token")
            UserDefaults.standard.removeObject(forKey: "id")
            UserDefaults.standard.removeObject(forKey: "description")
            UserDefaults.standard.removeObject(forKey: "name")
            UserDefaults.standard.removeObject(forKey: "profile_image")
            self.userInfoView.isHidden = true
            self.loginView.isHidden = false
            NotificationCenter.default.post(name: NSNotification.Name("updateProfileImage"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateStocks"), object: nil)
        }, onError: { (error) in
            self.showError(title: "Logout Failed", message: "Failed to disable your token. Please check your internet connection.")
        }, onCompleted: {
            
        }) {
            
        }.disposed(by: disposeBag)
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
