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
    
    func request(page: Int) -> Observable<Article>{
        return Observable.create({ (observer: AnyObserver<Article>) -> Disposable in
            Alamofire.request(HOST+API.Article.rawValue+"?page=\(page)").responseArray { (response: DataResponse<[Article]>) in
                if response.result.isSuccess {
                    let group = DispatchGroup()
                    for article in response.result.value! {
                        group.enter()
                        DispatchQueue(label: "getData").async(group: group) {
                            Alamofire.request((article.user?.profile_image_url)!).responseImage(completionHandler: { (response) in
                                if response.result.isSuccess {
                                    ArticleManager.sharedInstance.images.append(response.value!)
                                } else {
                                    ArticleManager.sharedInstance.images.append(UIImage(named: "ic_image")!)
                                }
                                ArticleManager.sharedInstance.articles.append(article)
                                group.leave()
                            })
                        }
                    }
                    group.notify(queue: .main, execute: {
                        observer.onCompleted()
                    })
                } else {
                    observer.onError(response.result.error!)
                    print("AlamofireObjectMapper failer")
                }
            }
            return Disposables.create()
        })
    }
}
