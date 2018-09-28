//
//  ArticleCollectionCell.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/28.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import WebKit

class ArticleCollectionCell: UICollectionViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var likes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(thumbnail: String, userName: String, title: String, likes: Int) {
        self.thumbnail.af_setImage(withURL: URL(string: thumbnail)!)
        self.userName.text = userName
        self.title.text = title
        self.likes.text = String(likes)
    }
}
