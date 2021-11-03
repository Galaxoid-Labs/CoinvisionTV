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
            ContentView()
                .environmentObject(dataProvider)
                .preferredColorScheme(getColorScheme())
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive {
                print("CryptoTV entered ==> inactive phase")
            } else if newPhase == .active {
                UIApplication.shared.isIdleTimerDisabled = true
                dataProvider.loadAll()
                Task {
                    await dataProvider.fetchAndSetCoinList()
                    await dataProvider.fetchAndSetMarketItems()
                }
                print("CryptoTV entered ==> active phase")
            } else if newPhase == .background {
                dataProvider.saveAll()
                print("CryptoTV entered ==> background phase")
            }
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
