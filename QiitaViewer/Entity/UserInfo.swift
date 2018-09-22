//
//  UserInfo.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/13.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import ObjectMapper

class UserInfo: Mappable {
    
    var id: String!
    var description: String!
    var profile_image_url: String!
    var name: String!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        description <- map["description"]
        profile_image_url <- map["profile_image_url"]
        name <- map["name"]
    }
}
