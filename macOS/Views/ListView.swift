//
//  ListView.swift
//  CoinvisionTV (macOS)
//
//  Created by Jacob Davis on 11/4/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Charts

struct ListView: View {
    
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
                    .frame(width: 80, alignment: .trailing)
                    .padding(.trailing, 32)
                Text("Market Cap")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .trailing)
                    .padding(.trailing, 24)
                Text("Price")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .trailing)
            }
            .padding(.vertical, 16)
            .padding(.trailing, 36)
            
            Divider()
            
            List {
                ForEach($dataProvider.marketItems) { $marketItem in
                    NavigationLink(destination: ListMarketItemDetailView(marketItemId: marketItem.id),
                                   label: {
                        ListViewItem(marketItem: marketItem)
                    })
                }
            }
            
        }
        .frame(minWidth: 450)

    }
    
}

struct ListView_Previews: PreviewProvider {
    static let dataProvider = DataProvider()
    static var previews: some View {
        ListView()
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
        
        HStack(spacing: 8) {
            
            WebImage(url: URL(string: marketItem.image))
                .interpolation(.high)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35, height: 35)
                .cornerRadius(6)

            VStack(alignment: .leading) {
                Text(marketItem.name)
                    .font(.body)
                    .bold()
                Text(marketItem.symbol.uppercased())
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 0)
            
            VStack(alignment: .trailing) {
                Text(marketItem.getTotalVolumeFormatted(forCurrency: dataProvider.currencyCode))
                    .font(.body)
                    .bold()
            }
            //.frame(width: 80)
            
            Divider()
            
            LazyVStack(alignment: .trailing) {
                Text(marketItem.getMarketCapFormatted(forCurrency: dataProvider.currencyCode))
                    .font(.body)
                    .bold()
                Text(marketItem.getMarketCapChangePercentage24HFormatted(forCurrency: dataProvider.currencyCode))
                    .font(.caption2)
                    .foregroundColor((marketItem.marketCapChangePercentage24H ?? .zero) > .zero ? .green : .red)
            }
            .frame(width: 80)
            
            Divider()
            
            LazyVStack(alignment: .trailing) {
                Text(marketItem.getCurrentPriceFormatted(forCurrency: dataProvider.currencyCode))
                    .font(.body)
                    .bold()
                Text(marketItem.getPriceChangePercentageFormatted(forCurrency: dataProvider.currencyCode))
                    .font(.caption2)
                    .foregroundColor((marketItem.priceChangePercentage24H ?? .zero) > .zero ? .green : .red)
            }
            .frame(width: 80)

        }
        .padding(8)
        
    }
}
