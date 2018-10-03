//
//  StockViewModel.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/19.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxSwift
import RxCocoa

class StockViewModel {
    
    let disposeBag = DisposeBag()
    
    let stockNotify = PublishRelay<[SectionOfArticle]>()
    
    var stocks:[ArticleStruct] = []
    
    var loading = false
    
    var page = 0
    
    func getStocks() -> Observable<[SectionOfArticle]>{
        return Observable.create({ (observer) -> Disposable in
            if !self.loading {
                self.loading = true
                self.page+=1
                StockRequest.shared.getStocks(page: self.page).subscribe(onNext: { (stocks) in
                    for stock in stocks {
                        self.stocks.append(ArticleStruct(id: stock.id!, title: stock.title!, url: stock.url!, likes: stock.likes, user: UserStruct(id: stock.user.id!, profile_image_url: stock.user.profile_image_url!)))
                    }
                    self.stockNotify.accept([SectionOfArticle(header: "", items: self.stocks)])
                }, onError: { (error) in
                    observer.onError(error)
                    self.endLoading()
                }, onCompleted: {
                    if self.stocks.count == 0 {
                        StockRequest.shared.isStockAvailable.accept(false)
                    } else {
                        StockRequest.shared.isStockAvailable.accept(true)
                    }
                    observer.onCompleted()
                    self.endLoading()
                }).disposed(by: self.disposeBag)            }
            return Disposables.create()
        })
    }
    
    func swipeRefresh() -> Observable<[SectionOfArticle]>{
        return Observable.create({ (observer) -> Disposable in
            if !self.loading {
                self.loading = true
                self.page = 1
                StockRequest.shared.getStocks(page: 1).subscribe(onNext: { (stocks) in
                    self.stocks.removeAll()
                    for stock in stocks {
                        self.stocks.append(ArticleStruct(id: stock.id!, title: stock.title!, url: stock.url!, likes: stock.likes, user: UserStruct(id: stock.user.id!, profile_image_url: stock.user.profile_image_url!)))
                    }
                    self.stockNotify.accept([SectionOfArticle(header: "", items: self.stocks)])
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
