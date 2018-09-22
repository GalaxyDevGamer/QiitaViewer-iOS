//
//  TagArticleViewModel.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/19.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RealmSwift
import RxCocoa

class TagArticleViewModel {
    
    var articles: [TagArticleStruct] = []
    
    let articleNotifier = PublishRelay<[SectionOfTagArticle]>()
    
    let isArticleAvailable = BehaviorRelay(value: false)
    
    var name: String!
    
    let tag = Tag()
    
    func loadArticles() {
        try! Realm().objects(Tag.self).filter("name = %@", name).first!.articles.forEach { (article) in
            self.articles.append(TagArticleStruct(id: article.id!, title: article.title!, url: article.url!, profile_image_url: article.image!, user_id: article.user_id))
            self.tag.articles.append(article)
        }
        articleNotifier.accept([SectionOfTagArticle(header: "", items: articles)])
        tag.name = name
        if self.articles.count > 0 {
            isArticleAvailable.accept(true)
        }
    }
    
    func removeArticle(index: Int) {
        articles.remove(at: index)
        tag.articles.remove(at: index)
        let realm = try! Realm()
        try! realm.write {
            realm.add(tag, update: true)
        }
        articleNotifier.accept([SectionOfTagArticle(header: "", items: articles)])
        if tag.articles.count == 0 {
            isArticleAvailable.accept(false)
        }
    }
}
