//
//  ArticleStruct.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/22.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxDataSources

struct ArticleStruct {
    var id: String
    var title: String
    var url:String
    var likes: Int
    var user: UserStruct
}
struct UserStruct {
    var id: String
    var profile_image_url: String
}

extension ArticleStruct: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: Identity {
        return self.id
    }
    
    static func == (lhs: ArticleStruct, rhs: ArticleStruct) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.url == rhs.url && lhs.likes == rhs.likes && lhs.user.id == rhs.user.id && lhs.user.profile_image_url == rhs.user.profile_image_url
    }
}
