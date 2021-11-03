//
//  CoinvisionTVApp.swift
//  Shared
//
//  Created by Jacob Davis on 11/3/21.
//

import SwiftUI

@main
struct CoinvisionTVApp: App {
    
    @StateObject var dataProvider = DataProvider()
    
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("colorTheme") var colorTheme: ColorTheme = ColorTheme.dark
    
    var body: some Scene {
        WindowGroup {
            #if os(tvOS)
            TVMainView()
                .environmentObject(dataProvider)
                .preferredColorScheme(getColorScheme())
                .onChange(of: scenePhase) { newPhase in
                    handle(scenePhase: newPhase)
                }
            #elseif os(macOS)
            MacMainView()
                .environmentObject(dataProvider)
                .preferredColorScheme(getColorScheme())
                .onChange(of: scenePhase) { newPhase in
                    handle(scenePhase: newPhase)
                }
            #else
            MainView()
                .environmentObject(dataProvider)
                .preferredColorScheme(getColorScheme())
                .onChange(of: scenePhase) { newPhase in
                    handle(scenePhase: newPhase)
                }
            #endif
        }
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
    
    func getColorScheme() -> ColorScheme {
        if colorTheme == .dark {
            return ColorScheme.dark
        } else {
            return ColorScheme.light
        }
    }
}
