//
//  IvoryApp.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 20/12/2022.
//

import SwiftUI
import SwiftUIComponents
import IvoryCore
import CommonUtils
import DependencyContainer
import Loader
import LoaderUI

@main
struct IvoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    
    @StateObject private var coordinator = TabsCoordinator()
    @State private var commonLoader = Loader()
    
    var body: some View {
        LoadingContainer(commonLoader) {
            coordinator.rootView
                .withFloatingPlayer(coordinator: coordinator)
                .tint(Color.tint)
                .accentColor(Color.tint)
                .withHostingWindow { window in
                    #if targetEnvironment(macCatalyst)
                    if let titlebar = window?.windowScene?.titlebar {
                        titlebar.titleVisibility = .hidden
                        titlebar.toolbar = nil
                    }
                    #endif
                }.statusBarHidden(false)
        }.environmentObject(commonLoader)
            .toolbarColorScheme(.light, for: .navigationBar)
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        DI.Container.setup()
    
        Task { try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) }
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("registered")
    }
        
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    @MainActor
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult { .newData }
}
