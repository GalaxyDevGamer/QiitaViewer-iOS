//
//  ArticleRequest.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/09.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxSwift
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class ArticleRequest {
    
    static let shaeredInstance = ArticleRequest()
    
    let disposeBag = DisposeBag()
    
    func request(page: Int) -> Observable<[Article]>{
        return Observable.create({ (observer: AnyObserver<[Article]>) -> Disposable in
            Alamofire.request(HOST+API.Article.rawValue, method: .get, parameters: ["page":page], encoding: URLEncoding.default, headers: nil).responseArray(completionHandler: { (response: DataResponse<[Article]>) in
                if response.result.isSuccess {
                    observer.onNext(response.result.value!)
                } else {
                    observer.onError(response.result.error!)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func getStocks(page: Int) -> Observable<[Article]> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(HOST+"/users/\(UserDefaults.standard.string(forKey: "id")!)/stocks", method: .get, parameters: ["page": page], encoding: URLEncoding.default, headers:nil).responseArray(completionHandler: { (response: DataResponse<[Article]>) in
                if response.result.isSuccess {
                    observer.onNext(response.result.value!)
                } else {
                    observer.onError(response.result.error!)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func downloadImage(url: String) -> Observable<UIImage> {
        return Observable.create({ (observer: AnyObserver<UIImage>) -> Disposable in
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                if response.result.isSuccess {
                    observer.onNext(response.result.value!)
                } else {
                    observer.onError(response.result.error!)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
}
