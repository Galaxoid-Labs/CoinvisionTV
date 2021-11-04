//
//  TilesView.swift
//  CoinvisionTV (macOS)
//
//  Created by Jacob Davis on 11/4/21.
//

import SwiftUI
import SDWebImageSwiftUI
import CoinGecko

//let xM: CGFloat = (1920/5) - 32

struct TilesView: View {
    
    @Binding var selectedMarketItem: MarketItem?
    
    @EnvironmentObject var dataProvider: DataProvider
    
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 175, maximum: 275))
    ]
    
    @State private var sortAlertPresented = false
    @State private var sortBy: CoinGecko.V3.Coins.Markets.Order = .market_cap_desc
    
    var marketItems: [MarketItem] {
        return dataProvider.marketItems
    }
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(marketItems) { marketItem in
                    TileView(selectedMarketItem: $selectedMarketItem, marketItem: marketItem)
                }
            }
            .padding()
//            .padding(.horizontal, 32)
//            .padding(.bottom, 32)
            
        }
        .frame(minWidth: 450)
        
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
                        .interpolation(.high)
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
            .padding(8)
            .background(LinearGradient(colors: [(isUp() ? .green.opacity(0.2) : .red.opacity(0.2)), (isUp() ? .green.opacity(0.1) : .red.opacity(0.1))], startPoint: .top, endPoint: .bottom))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isUp() ? .green : .red, lineWidth: 2)
            )
            .scaleEffect(isSelected() ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isSelected())
        }
        .buttonStyle(.plain)
        .opacity(isSelected() ? 0.65 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected())
        
    }
    
    func isSelected() -> Bool {
        return marketItem.id == selectedMarketItem?.id
    }
    
    func isUp() -> Bool {
        return (marketItem.priceChangePercentage24H ?? .zero) > .zero
    }
    
}

struct TilesView_Previews: PreviewProvider {
    static let dataProvider = DataProvider()
    static var previews: some View {
        TilesView(selectedMarketItem: .constant(nil)).environmentObject(dataProvider)
            .frame(width: 800, height: 300, alignment: .center)
            .task {
                await dataProvider.fetchAndSetMarketItems()
            }
    }
}
