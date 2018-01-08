//
//  TestAppDelegate.swift
//  C-MVVM
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import UIKit

final class TestAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {

        self.window?.rootViewController = UIViewController()

        return true
    }
}
