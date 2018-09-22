//
//  SectionOfTag.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/20.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxDataSources

struct SectionOfTag {
    var header: String
    var items: [Item]
}

extension SectionOfTag: AnimatableSectionModelType {
    typealias Item = TagStruct
    
    var identity: String {
        return header
    }
    
    init(original: SectionOfTag, items: [SectionOfTag.Item]) {
        self = original
        self.items = items
    }
}
