//
//  ListView.swift
//  CoinvisionTV
//
//  Created by Jacob Davis on 10/27/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Charts

struct ListView: View {
    
    @Binding var selectedMarketItem: MarketItem?
    
    @EnvironmentObject var dataProvider: DataProvider
    
    var marketItems: [MarketItem] {
        return dataProvider.marketItems
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                Spacer()
                Text("24h Volume")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: 250, alignment: .trailing)
                    .padding(.trailing, 32)
                Text("Market Cap")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: 250, alignment: .trailing)
                    .padding(.trailing, 24)
                Text("Price")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: 250, alignment: .trailing)
            }
            .padding(.bottom, 16)
            .padding(.trailing, 24)
            
            Divider()
            
            List {
                ForEach(marketItems) { marketItem in
                    Button(action: { self.selectedMarketItem = marketItem }) {
                        ListViewItem(marketItem: marketItem)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            
        }

    }
}

struct ListView_Previews: PreviewProvider {
    static let dataProvider = DataProvider()
    static var previews: some View {
        ListView(selectedMarketItem: .constant(nil))
            .environmentObject(dataProvider)
            .task {
                await dataProvider.fetchAndSetMarketItems()
            }
    }
}

struct ListViewItem: View {
    
    let marketItem: MarketItem
    @EnvironmentObject var dataProvider: DataProvider
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            WebImage(url: URL(string: marketItem.image))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 75, height: 75)
                .cornerRadius(16)

            VStack(alignment: .leading) {
                Text(marketItem.name)
                    .font(.body)
                    .bold()
                Text(marketItem.symbol.uppercased())
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            LazyVStack(alignment: .trailing) {
                Text(marketItem.getTotalVolumeFormatted(forCurrency: dataProvider.currencyCode))
                    .font(.body)
                    .bold()
            }
            .frame(width: 250)
            
            Divider()
            
            LazyVStack(alignment: .trailing) {
                Text(marketItem.getMarketCapFormatted(forCurrency: dataProvider.currencyCode))
                    .font(.body)
                    .bold()
                Text(marketItem.getMarketCapChangePercentage24HFormatted(forCurrency: dataProvider.currencyCode))
                    .font(.caption2)
                    .foregroundColor((marketItem.marketCapChangePercentage24H ?? .zero) > .zero ? .green : .red)
            }
            .frame(width: 250)
            
            Divider()
            
            LazyVStack(alignment: .trailing) {
                Text(marketItem.getCurrentPriceFormatted(forCurrency: dataProvider.currencyCode))
                    .font(.body)
                    .bold()
                Text(marketItem.getPriceChangePercentageFormatted(forCurrency: dataProvider.currencyCode))
                    .font(.caption2)
                    .foregroundColor((marketItem.priceChangePercentage24H ?? .zero) > .zero ? .green : .red)
            }
            .frame(width: 250)

        }
        .padding(8)
        
    }
}
