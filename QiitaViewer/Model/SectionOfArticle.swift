//
//  SectionOfArticle.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/22.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxDataSources

struct SectionOfArticle {
    var header: String
    var items: [Item]
}

extension SectionOfArticle: AnimatableSectionModelType {
    typealias Item = ArticleStruct
    
    var identity: String {
        return header
    }
    
    init(original: SectionOfArticle, items: [Item]) {
        self = original
        self.items = items
    }
}
