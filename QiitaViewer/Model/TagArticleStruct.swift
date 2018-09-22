//
//  ArticleStruct.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/21.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxDataSources

struct TagArticleStruct {
    let id:String
    let title: String
    let url:String
    let profile_image_url: String
    let user_id: String
}

extension TagArticleStruct: IdentifiableType, Equatable {
    typealias Identity = String
    var identity: Identity {
        return self.id
    }
    
    static func == (lhs: TagArticleStruct, rhs: TagArticleStruct) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.url == rhs.url && lhs.profile_image_url == rhs.profile_image_url && lhs.user_id == rhs.user_id
    }
}
