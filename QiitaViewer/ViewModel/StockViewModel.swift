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
    
    let showLoading = PublishRelay<Bool>()
    
    let refreshing = PublishRelay<Bool>()
    
    let notifyError = PublishRelay<Error>()
    
    var stocks:[ArticleStruct] = []
    
    var loading = false
    
    var page = 0
    
    func getStocks(){
        if loading {
            return
        }
        showLoading.accept(true)
        loading = true
        page+=1
        StockRequest.shared.getStocks(page: page).subscribe(onNext: { (stocks) in
            for stock in stocks {
                self.stocks.append(ArticleStruct(id: stock.id!, title: stock.title!, url: stock.url!, user: UserStruct(id: stock.user.id!, profile_image_url: stock.user.profile_image_url!)))
            }
            self.stockNotify.accept([SectionOfArticle(header: "", items: self.stocks)])
        }, onError: { (error) in
            self.notifyError.accept(error)
            self.endLoading()
        }, onCompleted: {
            if self.stocks.count == 0 {
                StockRequest.shared.isStockAvailable.accept(false)
            } else {
                StockRequest.shared.isStockAvailable.accept(true)
            }
            self.endLoading()
        }).disposed(by: disposeBag)
    }
    
    func swipeRefresh() {
        if loading {
            return
        }
        loading = true
        page = 0
        StockRequest.shared.getStocks(page: 1).subscribe(onNext: { (stocks) in
            self.stocks.removeAll()
            for stock in stocks {
                self.stocks.append(ArticleStruct(id: stock.id!, title: stock.title!, url: stock.url!, user: UserStruct(id: stock.user.id!, profile_image_url: stock.user.profile_image_url!)))
            }
            self.stockNotify.accept([SectionOfArticle(header: "", items: self.stocks)])
        }, onError: { (error) in
            self.notifyError.accept(error)
            self.refreshing.accept(true)
            self.loading = false
        }, onCompleted: {
            self.refreshing.accept(true)
            self.loading = false
        }).disposed(by: disposeBag)
    }
    
    func endLoading() {
        self.showLoading.accept(false)
        loading = false
    }
}
