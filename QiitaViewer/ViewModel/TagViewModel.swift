//
//  TagViewModel.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/19.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RealmSwift
import RxCocoa

class TagViewModel {
    
    let isTagAvailable = BehaviorRelay(value: false)
    
    let tagNotifier = PublishRelay<[SectionOfTag]>()
    
    var tags: [TagStruct] = []
    
    func loadTags() {
        let tagData = try! Realm().objects(Tag.self)
        if tagData.count == 0 {
            isTagAvailable.accept(false)
            return
        }
        for tag in tagData {
            tags.append(TagStruct(name: tag.name!))
        }
        tagUpdated()
    }
    
    func isTagExists(name: String) -> Bool {
        if try! Realm().objects(Tag.self).filter("name = %@", name).count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func addTag(name: String) {
        let realm = try! Realm()
        let tag = Tag()
        tag.name = name
        try! realm.write {
            realm.add(tag)
        }
        tags.append(TagStruct(name: name))
        tagUpdated()
    }
    
    func deleteTag(index: Int) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(Tag.self).filter("name = %@", tags[index].name).first!)
        }
        tags.remove(at: index)
        tagUpdated()
    }
    
    func tagUpdated() {
        tagNotifier.accept([SectionOfTag(header: "", items: tags)])
        if try! Realm().objects(Tag.self).count == 0 {
            isTagAvailable.accept(false)
        } else {
            isTagAvailable.accept(true)
        }
    }
}
