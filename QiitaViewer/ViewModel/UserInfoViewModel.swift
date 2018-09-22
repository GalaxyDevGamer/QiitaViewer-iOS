//
//  UserInfoViewModel.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/19.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxSwift
import RxCocoa
import AlamofireImage

class UserInfoViewModel {
    
    let disposeBag = DisposeBag()
    
    let errorNotifier = PublishRelay<String>()
    
    let showLoading = PublishRelay<Bool>()
    
    let user_id = PublishRelay<String>()
    
    let description = PublishRelay<String>()
    
    let profile_image = PublishRelay<UIImage>()
    
    let loginAlert = PublishRelay<Any>()
    
    func login() {
        UIApplication.shared.open(URL(string: AuthorizeURI)!, options: [:]) { result in
            if result == false {
                self.errorNotifier.accept("Failed to open browser")
            }
        }
    }
    
    func getUserInfo() {
        showLoading.accept(true)
        UserInfoRequest.sharedInstance.getUserInfo().subscribe(onNext: { (userInfo) in
            self.user_id.accept(userInfo.id)
            self.description.accept(userInfo.description)
            UserInfoRequest.sharedInstance.imageObserver.subscribe(onNext: { (image) in
                self.profile_image.accept(image!)
            }).disposed(by: self.disposeBag)
            UserInfoRequest.sharedInstance.getProfileImage(url: userInfo.profile_image_url)
            UserDefaults.standard.set(userInfo.id, forKey: "id")
            UserDefaults.standard.set(userInfo.profile_image_url, forKey: "profile_image")
//            self.profile_image.accept(AutoPurgingImageCache(memoryCapacity: UInt64(150) * 1024 * 1024, preferredMemoryUsageAfterPurge: UInt64(60) * 1024 * 1024).image(withIdentifier: userInfo.profile_image_url)!)
        }, onError: { (error) in
            self.loginAlert.accept(error)
            self.showLoading.accept(false)
        }, onCompleted: {
            self.showLoading.accept(false)
        }).disposed(by: disposeBag)
    }
    
    func logout() {
        UserInfoRequest.sharedInstance.logout().subscribe(onNext: { (isSuccess) in
            UserDefaults.standard.removeObject(forKey: "access_token")
            UserDefaults.standard.removeObject(forKey: "id")
            UserDefaults.standard.removeObject(forKey: "description")
            UserDefaults.standard.removeObject(forKey: "name")
            UserDefaults.standard.removeObject(forKey: "profile_image")
            NotificationCenter.default.post(name: NSNotification.Name("updateProfileImage"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AuthorizeStateChanged"), object: nil)
        }, onError: { (error) in
            self.errorNotifier.accept("Logout Failed. Please check your internet connection")
        }).disposed(by: disposeBag)
    }
}
