//
//  UserInfo.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/13.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import AlamofireObjectMapper
import AlamofireImage

class UserInfoRequest {
    static let sharedInstance = UserInfoRequest()
    
    let disposeBag = DisposeBag()
    
    func getUserInfo() -> Observable<UserInfo> {
        return Observable.create({ (obsever: AnyObserver<UserInfo>) -> Disposable in
            Alamofire.request(HOST+API.User.rawValue, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+UserDefaults.standard.string(forKey: "access_token")!]).responseObject(completionHandler: { (response: DataResponse<UserInfo>) in
                if response.result.isSuccess {
                    obsever.onNext(response.result.value!)
                } else {
                    obsever.onError(response.result.error!)
                }
                obsever.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func getProfileImage(url: String) -> Observable<UIImage> {
        return Observable.create({ (observer: AnyObserver<UIImage>) -> Disposable in
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                if response.result.isSuccess {
                    observer.onNext(response.result.value!)
                } else {
                    observer.onError(response.result.error!)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func logout() -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(HOST+"/access_tokens/"+UserDefaults.standard.string(forKey: "access_token")!, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                if response.response?.statusCode == 204 {
                    observer.onNext(true)
                } else {
                    observer.onError(response.error!)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
}
