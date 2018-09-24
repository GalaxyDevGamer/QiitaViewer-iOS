//
//  API.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/08/31.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import Foundation
import UIKit

let HOST = "https://qiita.com/api/v2"
let AuthorizeURI = "https://qiita.com/api/v2/oauth/authorize?client_id=bc3deb1194eff0ce4fd62e4d9e0e9fc628f942ea&scope=read_qiita+write_qiita&state=ab6s5adw121wsa2120ed7fe1"
let FailTitle = "Something went wrong"
let access_token = "Bearer " + UserDefaults.standard.string(forKey: "access_token")!
let header = ["Authorization":access_token]
let errorTitle = "Error"
let plsCheckInternet = "Please check your internet connection."
let cellHeight: CGFloat = 130



enum API: String {
    case Article = "/items"
    case Lectures = "/users/Galaxy/items"
    case User = "/authenticated_user"
}
