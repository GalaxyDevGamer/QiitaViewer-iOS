//
//  Articles.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/05/21.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers
class Articles: Object {
    dynamic var id:String?
    dynamic var title: String?
    dynamic var url:String?
    dynamic var profile_image_url: String?
    dynamic var user_id: String!
}
