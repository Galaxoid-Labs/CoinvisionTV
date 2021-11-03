//
//  MacMainView.swift
//  CoinvisionTV (macOS)
//
//  Created by Jacob Davis on 11/3/21.
//

import SwiftUI

struct MacMainView: View {
    
    @EnvironmentObject var dataProvider: DataProvider
    @State private var selectedMarketItem: MarketItem? = nil
    
    var body: some View {
        
        NavigationView {
            
            List {
                
                NavigationLink(destination: ListView(selectedMarketItem: $selectedMarketItem),
                               label: {
                    Text("List")
                })
                
                NavigationLink(destination: TilesView(selectedMarketItem: $selectedMarketItem),
                               label: {
                    Text("Tiles")
                })
                
                NavigationLink(destination: BubblesView(),
                               label: {
                    Text("Bubbles")
                })
                
                NavigationLink(destination: OptionsView(),
                               label: {
                    Text("Options")
                })
            }
            .listStyle(SidebarListStyle())
            
            ListView(selectedMarketItem: $selectedMarketItem)
            
        }
    }
}

struct MacMainView_Previews: PreviewProvider {
    static let dataProvider = DataProvider()
    static var previews: some View {
        MacMainView()
            .environmentObject(dataProvider)
    }
}
