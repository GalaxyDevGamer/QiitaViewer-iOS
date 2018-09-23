//
//  StockRequest.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/09/14.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import RxSwift
import RxCocoa
import Alamofire

class StockRequest {
    static let shared = StockRequest()
    let stockStatus = BehaviorRelay(value: false)
    let isStockAvailable = BehaviorRelay(value: false)
    
    func checkIsStocked(articleID: String) {
        Alamofire.request(HOST+"/items/\(articleID)/stock", method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).response { (response) in
            if response.response?.statusCode == 204 {
                self.stockStatus.accept(true)
            } else {
                self.stockStatus.accept(false)
            }
        }
    }
    
    func isStocked(articleID: String) -> Observable<Bool> {
        return stockStatus.asObservable()
    }
    
    func getStocks(page: Int) -> Observable<[Article]> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(HOST+"/users/\(UserDefaults.standard.string(forKey: "id")!)/stocks", method: .get, parameters: ["page": page], encoding: URLEncoding.default, headers:nil).responseArray(completionHandler: { (response: DataResponse<[Article]>) in
                if response.result.isSuccess {
                    observer.onNext(response.result.value!)
                } else {
                    observer.onError(response.result.error ?? "Failed to get stocks" as! Error)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func unStock(articleID: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(HOST+"/items/\(articleID)/stock", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: header).response { (response) in
                if response.response?.statusCode == 204 {
                    self.stockStatus.accept(false)
                    observer.onCompleted()
                } else {
                    observer.onError(response.error ?? "UnStock Failed" as! Error)
                }
            }
            return Disposables.create()
        })
    }
    
    func stock(articleID: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(HOST+"/items/\(articleID)/stock", method: .put, parameters: nil, encoding: URLEncoding.default, headers: header).response { (response) in
                if response.response?.statusCode == 204 {
                    self.stockStatus.accept(true)
                    observer.onCompleted()
                } else {
                    observer.onError(response.error ?? "Stock Failed" as! Error)
                }
            }
            return Disposables.create()
        })
    }
}
