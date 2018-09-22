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
    
    var lectureNotifier = PublishRelay<[SectionOfArticle]>()
    
    let showLoading = PublishRelay<Bool>()
    
    let refreshing = PublishRelay<Bool>()
    
    let errorNotifier = PublishRelay<Error>()
    
    let disposeBag = DisposeBag()
    
    func getLectures() {
        if loading {
            return
        }
        showLoading.accept(true)
        loading = true
        page+=1
        ArticleRequest.shared.getLectures(page: page).subscribe(onNext: { (lectures) in
            for lecture in lectures {
                self.lectures.append(ArticleStruct(id: lecture.id!, title: lecture.title!, url: lecture.url!, user: UserStruct(id: lecture.user.id!, profile_image_url: lecture.user.profile_image_url!)))
            }
            self.lectureNotifier.accept([SectionOfArticle(header: "", items: self.lectures)])
        }, onError: { (error) in
            self.errorNotifier.accept(error)
            self.showLoading.accept(false)
            self.loading = false
        }, onCompleted: {
            self.showLoading.accept(false)
            self.loading = false
        }).disposed(by: disposeBag)
    }
    
    func swipeRefresh() {
        if loading {
            return
        }
        loading = true
        page = 1
        ArticleRequest.shared.getLectures(page: 1).subscribe(onNext: { (lectures) in
            self.lectures.removeAll()
            for lecture in lectures {
                self.lectures.append(ArticleStruct(id: lecture.id!, title: lecture.title!, url: lecture.url!, user: UserStruct(id: lecture.user.id!, profile_image_url: lecture.user.profile_image_url!)))
            }
            self.lectureNotifier.accept([SectionOfArticle(header: "", items: self.lectures)])
        }, onError: { (error) in
            self.errorNotifier.accept(error)
            self.loading = false
            self.refreshing.accept(true)
        }, onCompleted: {
            self.loading = false
            self.refreshing.accept(true)
        }).disposed(by: disposeBag)
    }
}
