//
//  UserInfoObserver.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/17.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserInfoObserver: NSObject {
    
    static let shared = UserInfoObserver()
    
    let profile_image = BehaviorRelay(value: false)
    
    let disposeBag = DisposeBag()
    
    
    override required init() {
        super.init()
    }
    
    func getUserInfo() {
        UserInfoRequest.sharedInstance.getUserInfo().subscribe(onNext: { (userInfo) in
            UserDefaults.standard.set(userInfo.id, forKey: "id")
            UserDefaults.standard.set(userInfo.description, forKey: "description")
            UserDefaults.standard.set(userInfo.name, forKey: "name")
            UserDefaults.standard.set(userInfo.profile_image_url, forKey: "profile_image")
        }, onError: { (error) in
            print("Failed to get user info")
        }, onCompleted: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginSuccess"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("updateProfileImage"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AuthorizeStateChanged"), object: nil)
        }).disposed(by: disposeBag)
    }
}
