//
//  TabBarController.swift
//  QiitaViewer
//
//  Created by GINGA WATANABE on 2018/04/10.
//  Copyright © 2018 GalaxySoftware. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabBarController = UITabBarController()
        
        tabBarController.delegate = self
        var array:[UINavigationController] = []
        
        let homeView: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeBoard")
        let homeNav = UINavigationController(rootViewController: homeView)
        array.append(homeNav)
        let favouriteView: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavouriteBoard")
        let favNav = UINavigationController(rootViewController: favouriteView)
        array.append(favNav)
        let searchView: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchBoard")
        let searcgNav = UINavigationController(rootViewController: searchView)
        array.append(searcgNav)
        tabBarController.viewControllers = array
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
