//
//  LectureViewModel.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/19.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxSwift
import RxCocoa

class LectureViewModel {
    
    var page = 0
    
    var loading = false
    
    var lectures: [ArticleStruct] = []
    
    var lectureProvider = PublishRelay<[SectionOfArticle]>()
    
    let disposeBag = DisposeBag()
    
    func getLectures() -> Observable<[SectionOfArticle]>{
        return Observable.create { (observer) -> Disposable in
            if !self.loading {
                self.loading = true
                self.page+=1
                ArticleRequest.shared.getLectures(page: self.page).subscribe(onNext: { (lectures) in
                    for lecture in lectures {
                        self.lectures.append(ArticleStruct(id: lecture.id!, title: lecture.title!, url: lecture.url!, likes: lecture.likes, user: UserStruct(id: lecture.user.id!, profile_image_url: lecture.user.profile_image_url!)))
                    }
                    self.lectureProvider.accept([SectionOfArticle(header: "", items: self.lectures)])
                }, onError: { (error) in
                    observer.onError(error)
                    self.loading = false
                }, onCompleted: {
                    observer.onCompleted()
                    self.loading = false
                }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    func swipeRefresh() -> Observable<[SectionOfArticle]>{
        return Observable.create { (observer) -> Disposable in
            if !self.loading {
                self.loading = true
                self.page=1
                ArticleRequest.shared.getLectures(page: self.page).subscribe(onNext: { (lectures) in
                    self.lectures.removeAll()
                    for lecture in lectures {
                        self.lectures.append(ArticleStruct(id: lecture.id!, title: lecture.title!, url: lecture.url!, likes: lecture.likes, user: UserStruct(id: lecture.user.id!, profile_image_url: lecture.user.profile_image_url!)))
                    }
                    self.lectureProvider.accept([SectionOfArticle(header: "", items: self.lectures)])
                }, onError: { (error) in
                    observer.onError(error)
                    self.loading = false
                }, onCompleted: {
                    observer.onCompleted()
                    self.loading = false
                }).disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
}
