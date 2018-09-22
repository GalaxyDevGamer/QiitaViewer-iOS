//
//  TagModel.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/21.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxDataSources

struct TagStruct {
    let name: String
}

extension TagStruct: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: Identity {
        return self.name
    }
    
    static func == (lhs: TagStruct, rhs: TagStruct) -> Bool {
        return lhs.name == rhs.name
    }
}
