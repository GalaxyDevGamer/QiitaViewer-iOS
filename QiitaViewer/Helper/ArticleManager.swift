//
//  ArticleManager.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/13.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import Foundation
import UIKit

class ArticleManager: NSObject {
    
    static let sharedInstance = ArticleManager()
    
    var articles: [Article] = []
    var images: [UIImage] = []
    
    override required init() {
        
    }
    
    
}
