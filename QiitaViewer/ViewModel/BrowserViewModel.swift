//
//  BrowserViewModel.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/19.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift
import Alamofire

class BrowserViewModel {
    
    let loginAlert = PublishRelay<String>()
    
    let resultNotify = PublishRelay<String>()
    
    let stockImage = BehaviorRelay(value: UIImage(named: "UnStocked24pt")!)
    let likeImage = BehaviorRelay(value: UIImage(named: "UnLiked24pt")!)
    let tagImage = BehaviorRelay(value: UIImage(named: "Bookmark24pt")!)
    
    var isStocked = false
    
    var isLiked = false
    
    var articleID: String!
    
    let disposeBag = DisposeBag()
    
    let tags = try! Realm().objects(Tag.self)
    
    
    func checkStatus() {
        if UserDefaults.standard.string(forKey: "access_token") != nil {
            checkIsStocked()
            checkIsLiked()
        }
    }
    
    func checkIsStocked() {
        Alamofire.request(HOST+"/items/\(articleID!)/stock", method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).response { (response) in
            if response.response?.statusCode == 204 {
                self.isStocked = true
                self.stockImage.accept(UIImage(named: "Stocked24pt")!)
            }
        }
    }
    
    func checkIsLiked() {
        Alamofire.request(HOST+"/items/\(articleID!)/like", method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).response { (response) in
            if response.response?.statusCode == 204 {
                self.isLiked = true
                self.likeImage.accept(UIImage(named: "Liked24pt")!)
            }
        }
    }
    
    func stockClick() {
        if UserDefaults.standard.string(forKey: "id") == nil {
            loginAlert.accept("stock")
            return
        }
        if isStocked {
            StockRequest.shared.unStock(articleID: articleID!).subscribe(onError: { (error) in
                self.resultNotify.accept("UnStock Failed")
            }, onCompleted: {
                self.isStocked = false
                self.stockImage.accept(UIImage(named: "UnStocked24pt")!)
                self.resultNotify.accept("UnStocked")
            }).disposed(by: disposeBag)
        } else {
            StockRequest.shared.stock(articleID: articleID!).subscribe(onError: { (error) in
                self.resultNotify.accept("Stock Failed")
            }, onCompleted: {
                self.isStocked = true
                self.stockImage.accept(UIImage(named: "Stocked24pt")!)
                self.resultNotify.accept("Stocked")
            }).disposed(by: disposeBag)
        }
    }
    
    func likeClick() {
        if UserDefaults.standard.string(forKey: "id") == nil {
            loginAlert.accept("like")
            return
        }
        if isLiked {
            LikeRequest.shared.unLike(articleID: articleID!).subscribe(onError: { (error) in
                self.resultNotify.accept("UnLike Failed")
            }, onCompleted: {
                self.isLiked = false
                self.resultNotify.accept("UnLiked")
                self.likeImage.accept(UIImage(named: "UnLiked24pt")!)
            }).disposed(by: disposeBag)
        } else {
            LikeRequest.shared.like(articleID: articleID!).subscribe(onError: { (error) in
                self.resultNotify.accept("Like Failed")
            }, onCompleted: {
                self.isLiked = true
                self.resultNotify.accept("Liked")
                self.likeImage.accept(UIImage(named: "Liked24pt")!)
            }).disposed(by: disposeBag)
        }
    }
    
    func addToTag(name: String, title: String, url: String, image: String, user_id: String) {
        let realm = try! Realm()
        let data = realm.objects(Tag.self).filter("name = %@", name).first
        let article = Articles()
        article.id = self.articleID
        article.title = title
        article.url = url
        article.image = image
        article.user_id = user_id
        let saveData = Tag()
        saveData.name = name
        data?.articles.forEach({ (article) in
            saveData.articles.append(article)
        })
        saveData.articles.append(article)
        try! realm.write {
            realm.add(saveData, update: true)
        }
        resultNotify.accept("Add Success")
    }
}
