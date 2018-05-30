//
//  SearchHistory.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/05/25.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers
class SearchHistory: Object {
    dynamic var word: String?
    dynamic var date: String?
    
    override static func primaryKey() -> String? {
        return "word"
    }
}
