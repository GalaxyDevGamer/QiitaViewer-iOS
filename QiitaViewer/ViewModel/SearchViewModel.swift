//
//  SearchViewModel.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/19.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift

class SearchViewModel {
    
    var results: [ArticleStruct] = []
    
    var history: Results<SearchHistory>!
    
    var loading = false
    
    var page = 0
    
    var query: String!
    
    let disposeBag = DisposeBag()
    
    let resultProvider = PublishRelay<[SectionOfArticle]>()
    
    let historyNotifier = PublishRelay<Results<SearchHistory>>()
    
    func loadHistory() {
        history = try! Realm().objects(SearchHistory.self).sorted(byKeyPath: "date")
        historyNotifier.accept(history)
    }
    
    func clearResult() {
        results.removeAll()
        page = 0
    }
    
    func searchArticles(query: String) -> Observable<[SectionOfArticle]>{
        return Observable.create({ (observer) -> Disposable in
            if !self.loading {
                self.clearResult()
                self.page = 1
                self.loading = true
                self.query = query
                ArticleRequest.shared.search(page: self.page, query: query).subscribe(onNext: { (results) in
                    for result in results {
                        self.results.append(ArticleStruct(id: result.id!, title: result.title!, url: result.url!, likes: result.likes, user: UserStruct(id: result.user.id!, profile_image_url: result.user.profile_image_url!)))
                    }
                    self.resultProvider.accept([SectionOfArticle(header: "", items: self.results)])
                }, onError: { (error) in
                    observer.onError(error)
                    self.endLoading()
                }, onCompleted: {
                    observer.onCompleted()
                    self.endLoading()
                }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        })
    }
    
    func loadMore() -> Observable<[SectionOfArticle]>{
        return Observable.create({ (observer) -> Disposable in
            if !self.loading {
                self.page += 1
                self.loading = true
                ArticleRequest.shared.search(page: self.page, query: self.query).subscribe(onNext: { (results) in
                    for result in results {
                        self.results.append(ArticleStruct(id: result.id!, title: result.title!, url: result.url!, likes: result.likes, user: UserStruct(id: result.user.id!, profile_image_url: result.user.profile_image_url!)))
                    }
                    self.resultProvider.accept([SectionOfArticle(header: "", items: self.results)])
                }, onError: { (error) in
                    observer.onError(error)
                    self.endLoading()
                }, onCompleted: {
                    observer.onCompleted()
                    self.endLoading()
                }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        })
    }
    
    func addToHistory(text: String) {
        let realm = try! Realm()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        let date = Date()
        let history = SearchHistory()
        history.word = text
        history.date = formatter.string(from: date)
        try! realm.write {
            realm.add(history, update: true)
        }
    }
    func endLoading() {
        self.loading = false
    }
}
