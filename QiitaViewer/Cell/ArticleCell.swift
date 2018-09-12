//
//  ArticleCell.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/08/30.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var title: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(thumbnail:UIImage, user_id: String, title:String) {
        self.thumbnail.image = thumbnail
        self.user.text = user_id
        self.title.text = title
    }
}
