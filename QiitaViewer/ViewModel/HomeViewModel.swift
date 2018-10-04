//
//  HomeViewModel.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/18.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxSwift
import RxCocoa

class HomeViewModel {
    
    let disposeBag = DisposeBag()
    
    let articleProvider = PublishRelay<[SectionOfArticle]>()
    
    var articles:[ArticleStruct] = []
    
    var loading = false
    
    var page = 0
    
    func getArticle() -> Observable<[SectionOfArticle]>{
        return Observable.create({ (observer) -> Disposable in
            if !self.loading {
                self.loading = true
                self.page+=1
                //https://qiita.com/api/v2/items?per_page=%d&page=%d
                ArticleRequest.shared.getArticles(page: self.page).subscribe(onNext: { (articles) in
                    for article in articles {
                        self.articles.append(ArticleStruct(id: article.id!, title: article.title!, url: article.url!, likes: article.likes, user: UserStruct(id: article.user.id!, profile_image_url: article.user.profile_image_url!)))
                    }
                    self.articleProvider.accept([SectionOfArticle(header: "", items: self.articles)])
                    observer.onNext([SectionOfArticle(header: "", items: self.articles)])
                }, onError: { (error) in
                    print("loading")
                    observer.onError(error)
                    self.endLoading()
                }, onCompleted: {
                    print("onComplete")
                    observer.onCompleted()
                    self.endLoading()
                }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        })
    }
    
    func swipeRefresh() -> Observable<[SectionOfArticle]>{
        return Observable.create({ (observer) -> Disposable in
            if !self.loading {
                self.loading = true
                self.page = 1
                ArticleRequest.shared.getArticles(page: 1).subscribe(onNext: { (articles) in
                    self.articles.removeAll()
                    for article in articles {
                        self.articles.append(ArticleStruct(id: article.id!, title: article.title!, url: article.url!, likes: article.likes, user: UserStruct(id: article.user.id!, profile_image_url: article.user.profile_image_url!)))
                    }
                    self.articleProvider.accept([SectionOfArticle(header: "", items: self.articles)])
                }, onError: { (error) in
                    observer.onError(error)
                    self.loading = false
                }, onCompleted: {
                    observer.onCompleted()
                    self.loading = false
                }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        })
    }
    
    func endLoading() {
        loading = false
    }
}
