//
//  TVMainView.swift
//  CoinvisionTV (tvOS)
//
//  Created by Jacob Davis on 11/3/21.
//

import SwiftUI

struct TVMainView: View {
    
    @EnvironmentObject var dataProvider: DataProvider
    @State private var selectedMarketItem: MarketItem? = nil
    
    var body: some View {
        TabView {
            ListView(selectedMarketItem: $selectedMarketItem)
                .tabItem {
                    Text("List")
                }
            TilesView(selectedMarketItem: $selectedMarketItem)
                .tabItem {
                    Text("Tiles")
                }
            BubblesView()
                .tabItem {
                    Text("Bubbles")
                }
            OptionsView()
                .tabItem {
                    Text("Options")
                }
        }
        .sheet(item: $selectedMarketItem, onDismiss: {
            selectedMarketItem = nil
        }, content: { item in
            MarketItemDetailView(marketItemId: item.id)
        })
    }
}

struct TVMainView_Previews: PreviewProvider {
    static let dataProvider = DataProvider()
    static var previews: some View {
        TVMainView()
            .environmentObject(dataProvider)
    }
}
