//
//  AppDelegate.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/04/10.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarDelegate {
    
    var window: UIWindow?
    var isFavouriteModified: Bool?
    var tabBar: UITabBar!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code"})?.value
        Alamofire.request("https://qiita.com/api/v2/access_tokens", method: .post, parameters: ["client_id":"bc3deb1194eff0ce4fd62e4d9e0e9fc628f942ea", "client_secret":"fd50c24ed944996c3aa68c2ae0f7cd696dbb7ff9", "code":code!], encoding: URLEncoding(destination: .queryString), headers: nil).responseJSON { (reponse) in
            if reponse.result.isSuccess {
                let json = JSON(reponse.value as Any)
                print(reponse.value as Any)
                UserDefaults.standard.set(json["token"].string, forKey: "access_token")
                self.getUserInfo()
            } else {
                print("Failed to get access_token")
            }
        }
        return true
    }
    
    func getUserInfo() {
        Alamofire.request("https://qiita.com/api/v2/authenticated_user", method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+UserDefaults.standard.string(forKey: "access_token")!]).responseJSON { (reponse) in
            if reponse.result.isSuccess {
                let json = JSON(reponse.value as Any)
                UserDefaults.standard.set(json["id"].string, forKey: "id")
                UserDefaults.standard.set(json["description"].string, forKey: "description")
                UserDefaults.standard.set(json["name"].string, forKey: "name")
                UserDefaults.standard.set(json["profile_image_url"].string, forKey: "profile_image")
                NotificationCenter.default.post(name: NSNotification.Name("showUserInfo"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginSuccess"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name("updateProfileImage"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateStocks"), object: nil)
            } else {
                print("Failed to get user info")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "QiitaViewer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

