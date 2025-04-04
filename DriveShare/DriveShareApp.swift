//
//  DriveShareApp.swift
//  DriveShare
//
//  Created by Christopher Woods on 3/17/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}



@main
struct DriveShareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel = SignInEmaiLViewModel()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(viewModel)
        }
    }
}
