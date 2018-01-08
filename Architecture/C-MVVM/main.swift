//
//  main.swift
//  C-MVVM
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import UIKit

let isTestRunning = NSClassFromString("XCTestCase") != nil
let unsafeArguments = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))

if isTestRunning {
    UIApplicationMain(CommandLine.argc, unsafeArguments, nil, NSStringFromClass(TestAppDelegate.self))
} else {
    UIApplicationMain(CommandLine.argc, unsafeArguments, nil, NSStringFromClass(AppDelegate.self))
}
