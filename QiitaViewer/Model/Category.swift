//
//  Folders.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/05/23.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers
class Category: Object {
    dynamic var name: String?
    let articles = List<Articles>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
