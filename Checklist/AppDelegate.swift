//
//  AppDelegate.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?

}

extension AppDelegate: UIApplicationDelegate {

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        let splitViewController = self.window?.rootViewController as? UISplitViewController
        splitViewController?.delegate = self

        return true
    }

}

extension AppDelegate: UISplitViewControllerDelegate {

    func splitViewController(splitViewController: UISplitViewController,
                             collapseSecondaryViewController secondaryViewController: UIViewController,
                             ontoPrimaryViewController primaryViewController: UIViewController) -> Bool
    {
        let navigationController = secondaryViewController as? UINavigationController
        guard let viewController = navigationController?.topViewController as? DetailViewController else {
                return false
        }

        if viewController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing;
            // the secondary controller will be discarded.
            return true
        }
        
        return false
    }

}