//
//  TilesView.swift
//  CoinvisionTV
//
//  Created by Jacob Davis on 10/30/21.
//

import SwiftUI
import SDWebImageSwiftUI
import CoinGecko

let xM: CGFloat = (1920/5) - 32

struct TilesView: View {
    
    @Binding var selectedMarketItem: MarketItem?
    
    @EnvironmentObject var dataProvider: DataProvider
    
    let columns = [
        GridItem(.flexible(minimum: xM, maximum: xM)),
        GridItem(.flexible(minimum: xM, maximum: xM)),
        GridItem(.flexible(minimum: xM, maximum: xM)),
        GridItem(.flexible(minimum: xM, maximum: xM)),
        GridItem(.flexible(minimum: xM, maximum: xM))
    ]
    
    @State private var sortAlertPresented = false
    @State private var sortBy: CoinGecko.V3.Coins.Markets.Order = .market_cap_desc
    
    var marketItems: [MarketItem] {
        return dataProvider.marketItems
    }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 32) {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(marketItems) { marketItem in
                        TileView(selectedMarketItem: $selectedMarketItem, marketItem: marketItem)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            
        }
        
    }
}

struct TileView: View {
    
    @Binding var selectedMarketItem: MarketItem?
    let marketItem: MarketItem
    
    @EnvironmentObject var dataProvider: DataProvider
    
    var body: some View {
        
        Button(action: { self.selectedMarketItem = marketItem }) {
            LazyVStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    WebImage(url: URL(string: marketItem.image))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .cornerRadius(8)
                    Text(marketItem.symbol.uppercased())
                        .font(.headline)
                        
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(marketItem.getCurrentPriceFormatted(forCurrency: dataProvider.currencyCode))
                        .font(.headline)
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("24h")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(marketItem.getPriceChangePercentageFormatted(forCurrency: dataProvider.currencyCode))
                        .font(.caption)
                        .foregroundColor(isUp() ? .green : .red)
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("Volume")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(marketItem.getTotalVolumeFormatted(forCurrency: dataProvider.currencyCode))
                        .font(.caption2)
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("Market Cap")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(marketItem.getMarketCapFormatted(forCurrency: dataProvider.currencyCode))
                        .font(.caption2)
                }
                Spacer()
            }
            .padding()
            .frame(width: xM)
            .frame(height: xM * 0.65)
            .overlay(
                RoundedRectangle(cornerRadius: 13)
                    .stroke(isUp() ? .green : .red, lineWidth: 10)
            )

        }
        #if os(tvOS)
        .buttonStyle(CardButtonStyle())
        #endif
        .padding(.bottom, 24)
        
    }
    
    func isUp() -> Bool {
        return (marketItem.priceChangePercentage24H ?? .zero) > .zero
    }
    
}

struct TilesView_Previews: PreviewProvider {
    static let dataProvider = DataProvider()
    static var previews: some View {
        TilesView(selectedMarketItem: .constant(nil)).environmentObject(dataProvider)
            .task {
                await dataProvider.fetchAndSetMarketItems()
            }
    }
}
