//
//  User.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/01.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//
import ObjectMapper

class User: Mappable {
    
    var id: String?
    var profile_image_url: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping (map: Map) {
        id <- map["id"]
        profile_image_url <- map["profile_image_url"]
    }
}
