//
//  UserInfoView.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/08/31.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class UserInfoView: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var user_id: UILabel!
    @IBOutlet weak var user_description: UITextView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userInfoView: UIView!
    
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
        Alamofire.request(HOST+API.User.rawValue, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+UserDefaults.standard.string(forKey: "access_token")!]).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.value as Any)
                Alamofire.request(json["profile_image_url"].string!).responseImage(completionHandler: { (response) in
                    if response.result.isSuccess {
                        self.thumbnail.image = response.value
                    }
                })
                self.user_id.text = json["id"].string
                self.user_description.text = json["description"].string
                UserDefaults.standard.set(json["id"].string, forKey: "id")
                UserDefaults.standard.set(json["profile_image_url"].string, forKey: "profile_image")
            } else {
                let loginAlert = UIAlertController(title: "Connection Failed", message: "Unable to get UserInfo", preferredStyle: UIAlertController.Style.alert)
                loginAlert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { action in
                    self.loadUserInfoView()
                }))
                loginAlert.addAction(UIAlertAction(title: "Login again", style: UIAlertAction.Style.default, handler: { (action) in
                    self.openBrowser()
                }))
                self.present(loginAlert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginClick(_ sender: Any) {
        openBrowser()
    }
    
    func openBrowser() {
        UIApplication.shared.open(URL(string: AuthorizeURI)!, options: [:]) { result in
            if result == false {
                let alert = UIAlertController(title: "", message: "Failed to open browser", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func logoutClick(_ sender: Any) {
        Alamofire.request(HOST+"/access_tokens/"+UserDefaults.standard.string(forKey: "access_token")!, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: nil).response { (response) in
            if response.response?.statusCode == 204 {
                UserDefaults.standard.removeObject(forKey: "access_token")
                UserDefaults.standard.removeObject(forKey: "id")
                UserDefaults.standard.removeObject(forKey: "description")
                UserDefaults.standard.removeObject(forKey: "name")
                UserDefaults.standard.removeObject(forKey: "profile_image")
                self.userInfoView.isHidden = true
                self.loginView.isHidden = false
                NotificationCenter.default.post(name: NSNotification.Name("updateProfileImage"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateStocks"), object: nil)
            } else {
                let alert = UIAlertController(title: "Logout Failed", message: "Failed to disable your token. Please check your internet connection.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
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
