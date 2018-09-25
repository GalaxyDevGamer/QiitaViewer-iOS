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
    
    let articleNotify = PublishRelay<[SectionOfArticle]>()
    
    let showLoading = PublishRelay<Bool>()
    
    let endRefreshing = PublishRelay<Bool>()
    
    let notifyError = PublishRelay<Error>()
    
    var articles:[ArticleStruct] = []
    
    var loading = false
    
    var page = 0
    
    func getArticle() {
        if loading {
            return
        }
        showLoading.accept(true)
        loading = true
        page+=1
        print("current page:\(page)")
        //https://qiita.com/api/v2/items?per_page=%d&page=%d
        ArticleRequest.shared.getArticles(page: page).subscribe(onNext: { (articles) in
            for article in articles {
                self.articles.append(ArticleStruct(id: article.id!, title: article.title!, url: article.url!, likes: article.likes, user: UserStruct(id: article.user.id!, profile_image_url: article.user.profile_image_url!)))
            }
            self.articleNotify.accept([SectionOfArticle(header: "", items: self.articles)])
        }, onError: { (error) in
            self.notifyError.accept(error)
            self.endLoading()
        }, onCompleted: {
            self.endLoading()
        }).disposed(by: disposeBag)
    }
    
    func swipeRefresh() {
        if loading {
            return
        }
        loading = true
        page = 1
        ArticleRequest.shared.getArticles(page: 1).subscribe(onNext: { (articles) in
            self.articles.removeAll()
            for article in articles {
                self.articles.append(ArticleStruct(id: article.id!, title: article.title!, url: article.url!, likes: article.likes, user: UserStruct(id: article.user.id!, profile_image_url: article.user.profile_image_url!)))
            }
            self.articleNotify.accept([SectionOfArticle(header: "", items: self.articles)])
        }, onError: { (error) in
            self.notifyError.accept(error)
            self.endRefreshing.accept(true)
            self.loading = false
        }, onCompleted: {
            self.endRefreshing.accept(true)
            self.loading = false
        }).disposed(by: disposeBag)
    }
    
    func endLoading() {
        self.showLoading.accept(false)
        loading = false
    }
}
