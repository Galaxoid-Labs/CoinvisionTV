//
//  CoinvisionTVApp.swift
//  Shared
//
//  Created by Jacob Davis on 11/3/21.
//

import SwiftUI

@main
struct CoinvisionTVApp: App {
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #endif
    @StateObject var dataProvider = DataProvider()
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            #if os(tvOS)
            TVMainView()
                .environmentObject(dataProvider)
                .preferredColorScheme(dataProvider.getColorScheme())
                .onChange(of: scenePhase) { newPhase in
                    handle(scenePhase: newPhase)
                }
            #elseif os(macOS)
            MacMainView()
                .environmentObject(dataProvider)
                .preferredColorScheme(dataProvider.getColorScheme())
                .onChange(of: scenePhase) { newPhase in
                    handle(scenePhase: newPhase)
                }
                .frame(minWidth: 900, minHeight: 380, idealHeight: 780)
            #else
            MainView()
                .environmentObject(dataProvider)
                .preferredColorScheme(getColorScheme())
                .onChange(of: scenePhase) { newPhase in
                    handle(scenePhase: newPhase)
                }
            #endif
        }
        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(dataProvider)
                .preferredColorScheme(dataProvider.getColorScheme())
        }
        #endif
    }
    
    func handle(scenePhase: ScenePhase) {
        if scenePhase == .inactive {
            print("CoinvisionTV entered ==> inactive phase")
        } else if scenePhase == .active {
            #if os(tvOS)
            UIApplication.shared.isIdleTimerDisabled = true
            #endif
            dataProvider.loadAll()
            Task {
                await dataProvider.fetchAndSetCoinList()
                await dataProvider.fetchAndSetMarketItems()
            }
            print("CoinvisionTV entered ==> active phase")
        } else if scenePhase == .background {
            dataProvider.saveAll()
            print("CoinvisionTV entered ==> background phase")
        }
    }
    
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidChangeOcclusionState(_ notification: Notification) {
        if let window = NSApp.windows.first, window.isMiniaturized {
            NSWorkspace.shared.runningApplications.first(where: {
                $0.activationPolicy == .regular
            })?.activate(options: .activateAllWindows)
        }
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        if let window = NSApp.windows.first {
            window.deminiaturize(nil)
        }
    }
    
    lazy var windows = NSWindow()
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
         if !flag {
             for window in sender.windows {
                 window.makeKeyAndOrderFront(self)
             }
         }
         return true
     }
}
#endif
