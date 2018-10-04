//
//  ViewProvider.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/10/05.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import Foundation
import UIKit

class ViewProvider {
    
    static let get = ViewProvider()
    
    func userInfoView() -> UserInfoView {
        return UIStoryboard(name: "UserInfo", bundle: nil).instantiateViewController(withIdentifier: "UserInfoBoard") as! UserInfoView
    }
    
    func browser(article: ArticleStruct) -> BrowserView {
        let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
        view.articleID = article.id
        view.articleTitle = article.title
        view.articleUrl = article.url
        view.articleImage = article.user.profile_image_url
        view.user_id = article.user.id
        return view
    }
    
    func tagArticleView(name: String) -> TagArticleView {
        let view = UIStoryboard(name: "TagArticle", bundle: nil).instantiateViewController(withIdentifier: "TagArticleBoard") as! TagArticleView
        view.name = name
        return view
    }
    
    func openBrowserFromTag(article: TagArticleStruct) -> BrowserView {
        let view = UIStoryboard(name: "Browser", bundle: nil).instantiateViewController(withIdentifier: "BrowserBoard") as! BrowserView
        view.articleID = article.id
        view.articleTitle = article.title
        view.articleUrl = article.url
        view.articleImage = article.profile_image_url
        view.user_id = article.user_id
        return view
    }
}
