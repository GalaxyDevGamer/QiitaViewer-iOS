//
//  SectionOfArticle.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/21.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxDataSources

struct SectionOfTagArticle {
    var header: String
    var items: [Item]
}

extension SectionOfTagArticle: AnimatableSectionModelType {
    typealias Item = TagArticleStruct

    var identity : String {
        return header
    }
    
    init(original: SectionOfTagArticle, items: [Item]) {
        self = original
        self.items = items
    }
}
