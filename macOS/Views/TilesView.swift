//
//  TilesView.swift
//  CoinvisionTV (macOS)
//
//  Created by Jacob Davis on 11/4/21.
//

import SwiftUI
import SDWebImageSwiftUI
import CoinGecko

struct TilesView: View {
    
    @State private var selectedMarketItem: MarketItem?
    @State private var isDetailActive = false
    
    @EnvironmentObject var dataProvider: DataProvider
    
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 175, maximum: 275))
    ]
    
    @State private var sortAlertPresented = false
    @State private var sortBy: CoinGecko.V3.Coins.Markets.Order = .market_cap_desc
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            NavigationLink(destination: ListMarketItemDetailView(marketItemId: selectedMarketItem?.id ?? "bitcoin"), isActive: $isDetailActive) { EmptyView().hidden() }
            .frame(height: 0)
            .hidden()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(dataProvider.marketItems) { marketItem in
                        Button(action: { self.selectedMarketItem = marketItem; self.isDetailActive = true }) {
                            TileView(marketItem: marketItem, isSelected: self.selectedMarketItem?.id == marketItem.id)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            
        }
        .frame(minWidth: 450)
    }
}

struct TileView: View {
    
    let marketItem: MarketItem
    let isSelected: Bool
    
    @EnvironmentObject var dataProvider: DataProvider
    
    var body: some View {
        
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
        .cornerRadius(8)
        .overlay(

            isSelected ?
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.accentColor, lineWidth: 2)
            :
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isUp() ? .green : .red, lineWidth: 2)

        )
        
    }
    
    func isUp() -> Bool {
        return (marketItem.priceChangePercentage24H ?? .zero) > .zero
    }
    
}

//struct TilesView_Previews: PreviewProvider {
//    static let dataProvider = DataProvider()
//    static var previews: some View {
//        TilesView(selectedMarketItem: .constant(nil)).environmentObject(dataProvider)
//            .frame(width: 800, height: 300, alignment: .center)
//            .task {
//                await dataProvider.fetchAndSetMarketItems()
//            }
//    }
//}
