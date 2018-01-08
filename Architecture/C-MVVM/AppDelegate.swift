//
//  AppDelegate.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import UIKit

final class AppDelegate: UIResponder, UIApplicationDelegate {

    private var appCoordinator: AppCoordinator?

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.appCoordinator = AppCoordinator(navigationController: self.window?.rootViewController as? UINavigationController)

        self.appCoordinator?.start()

        return true
    }
}
