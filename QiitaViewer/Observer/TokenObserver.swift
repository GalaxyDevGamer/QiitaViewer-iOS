//
//  TokenObserver.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/15.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TokenObserver: NSObject {
    
    static let shared = TokenObserver()
    
    let authorizeState = BehaviorRelay(value: false)
    
    let disposeBag = DisposeBag()
    
    
    required override init() {
        super.init()
    }
    
    func addStateChangedObserver() {
        NotificationCenter.default.rx.notification(Notification.Name("AuthorizeStateChanged"), object: nil).subscribe(onNext: { (notification) in
            self.isAuthorized()
        }).disposed(by: disposeBag)
        isAuthorized()
    }
    
    func authorizeStateObserver() -> Observable<Bool> {
        return authorizeState.asObservable()
    }
    
    private func isAuthorized() {
        if UserDefaults.standard.string(forKey: "access_token") == nil {
            authorizeState.accept(false)
        } else {
            authorizeState.accept(true)
        }
    }
}
