//
//  Article.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/08/31.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import ObjectMapper

class Article: Mappable {
    
    var id:String?
    var title: String?
    var url:String?
    var user: User!
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        url <- map["url"]
        user <- map["user"]
    }
}
