//
//  LikeRequest.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/15.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxSwift
import RxCocoa
import Alamofire

class LikeRequest {
    static let shared = LikeRequest()
    let isLiked = BehaviorRelay(value: false)
    
    
    func checkIsLiked(articleID: String) {
        Alamofire.request(HOST+"/items/\(articleID)/like", method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).response { (response) in
            if response.response?.statusCode == 204 {
                self.isLiked.accept(true)
            } else {
                self.isLiked.accept(true)
            }
        }
    }
    
    func isLiked(articleID: String) -> Observable<Bool> {
        return isLiked.asObservable()
    }
    
    func unLike(articleID: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(HOST+"/items/\(articleID)/like", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: header).response { (response) in
                if response.response?.statusCode == 204 {
                    self.isLiked.accept(false)
                    observer.onCompleted()
                } else {
                    observer.onError(response.error ?? "UnLike Failed" as! Error)
                }
            }
            return Disposables.create()
        })
    }
    
    func like(articleID: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(HOST+"/items/\(articleID)/like", method: .put, parameters: nil, encoding: URLEncoding.default, headers: header).response { (response) in
                if response.response?.statusCode == 204 {
                    self.isLiked.accept(true)
                    observer.onCompleted()
                } else {
                    observer.onError(response.error ?? "Like Failed" as! Error)
                }
            }
            return Disposables.create()
        })
    }
}
