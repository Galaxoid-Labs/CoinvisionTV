//
//  ListMarketItemDetailView.swift
//  CoinvisionTV (macOS)
//
//  Created by Jacob Davis on 11/4/21.
//

import SwiftUI
import SDWebImageSwiftUI
import CoinGecko
import SwiftSoup
import Charts

struct ListMarketItemDetailView: View {
    
    let marketItemId: String
    
    @EnvironmentObject var dataProvider: DataProvider
    
    @State private var loading = true
    @State private var chartSegment: Int = 0
    @State private var marketItemChartPrices: MarketItemChart? =  nil
    @State private var marketItemDetail: MarketItemDetail? = nil
    @State private var chartXLabels: [String] = []
    @State private var chartYData: [Double] = []
    @State private var percentageChange: CoinGecko.V3.Coins.Markets.PriceChangePeriod = .percentage24h
    
    var marketItem: MarketItem? {
        return dataProvider.marketItems.first(where: { $0.id == marketItemId })
    }
    
    var body: some View {
        
        VStack {
            
            List {
                
                LazyVStack(alignment: .center, spacing: 0) {
                    
                    HStack(spacing: 8) {

                        WebImage(url: URL(string: marketItem?.image ?? ""))
                            .interpolation(.high)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)

                        VStack(alignment: .leading) {
                            Text(marketItem?.name ?? "")
                                .font(.largeTitle)
                                .bold()
                            Text(marketItem?.symbol.uppercased() ?? "")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(marketItem?.getCurrentPriceFormatted(forCurrency: dataProvider.currencyCode) ?? "")
                                .font(.largeTitle)
                                .bold()
                            Text("Price (\(dataProvider.currencyCode.uppercased()))")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }

                    }
                    
                    Divider()
                        .padding(.vertical, 16)

                    Picker("", selection: $chartSegment) {
                        Text("24H").tag(0)
                        Text("7D").tag(1)
                        Text("1M").tag(2)
                        Text("6M").tag(3)
                        Text("1Y").tag(4)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: chartSegment) { _ in
                        Task {
                            await load(marketItemId: marketItemId)
                        }
                    }
                    .frame(maxWidth: 300)
                    .padding(.bottom, 16)
                    
                    HStack(spacing: 16) {
                        
                        if loading {
                            VStack(spacing: 8) {
                                ProgressView()
                                Text("Fetching charts...")
                            }
                            .frame(height: 200)

                        } else {
                            
                            VStack(alignment: .leading) {
                                Text("\((marketItemChartPrices?.simplifiedYAxisValues().first ?? .zero).formatted(.currency(code: dataProvider.currencyCode).precision(.fractionLength(2...6))))")
                                    //.padding()
                                    .shadow(radius: 1)
                                Spacer()
                                Text("\((marketItemChartPrices?.simplifiedYAxisValues()[1] ?? .zero).formatted(.currency(code: dataProvider.currencyCode).precision(.fractionLength(2...6))))")
                                    //.padding()
                                    .shadow(radius: 1)
                                Spacer()
                                Text("\((marketItemChartPrices?.simplifiedYAxisValues().last ?? .zero).formatted(.currency(code: dataProvider.currencyCode).precision(.fractionLength(2...6))))")
                                    //.padding()
                                    .shadow(radius: 1)

                            }
                            .font(.caption)
                            
                            VStack {
                                ZStack {
                                    Chart(data: marketItemChartPrices?.normalizedPrices() ?? [])
                                        .chartStyle(
                                            AreaChartStyle(.quadCurve, fill:
                                                            LinearGradient(gradient: .init(colors: [chartIsUp() ? Color.green.opacity(0.3) : Color.red.opacity(0.3), chartIsUp() ? Color.green.opacity(0.08) : Color.red.opacity(0.08)]), startPoint: .top, endPoint: .bottom)
                                            )
                                        )
                                        .frame(height: 200)
                                    Chart(data: marketItemChartPrices?.normalizedPrices() ?? [])
                                        .chartStyle(
                                            LineChartStyle(.quadCurve, lineColor: chartIsUp() ? Color.green : Color.red, lineWidth: 2)
                                        )
                                        .frame(height: 200)
                                        .offset(x: 0, y: 1)
                                }
                            }
                            .background(Material.ultraThinMaterial)
                            .cornerRadius(8)
                        }

                    }

                }
                .padding()
                .background(Material.ultraThinMaterial)
                .cornerRadius(8)
                
                Section("Stats") {
                    getSectionStats()
                }

                if !(marketItemDetail?.getFormattedDescription(forLocale: dataProvider.languageCode) ?? "").isEmpty {
                    Section("About") {
                        LazyVStack {
                            Text(marketItemDetail?.getFormattedDescription(forLocale: dataProvider.languageCode) ?? "")
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                                .redacted(reason: loading ? .placeholder : [])
                        }
                        .padding()
                        .background(Material.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                }

            }
            
        }
        .task {
            await load(marketItemId: marketItemId)
        }
        .onChange(of: marketItemId) { newValue in
            Task {
                await load(marketItemId: newValue)
            }
        }
        .frame(minWidth: 450, idealWidth: 600)

    }
    
    fileprivate func getSectionStats() -> some View {
        return VStack(spacing: 16) {
            
            Group {
                HStack {
                    Text("Rank by Marketcap")
                    Spacer()
                    Text("#\(marketItem?.marketCapRank ?? 1)")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Market Cap")
                    Spacer()
                    Text(marketItem?.marketCap?.formatCurrencyAbreviation(currencyCode: dataProvider.currencyCode) ?? "")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("All Time High")
                    Spacer()
                    Text(marketItem?.ath?.formatted(.currency(code: dataProvider.currencyCode).precision(.fractionLength(2...4))) ?? "")
                        .foregroundColor(.secondary)
                }

                Divider()
            }
            
            Group {
                HStack {
                    Text("All Time Low")
                    Spacer()
                    Text(marketItem?.atl?.formatted(.currency(code: dataProvider.currencyCode).precision(.fractionLength(2...4))) ?? "")
                        .foregroundColor(.secondary)
                }

                Divider()
                
                HStack {
                    Text("Trading Volume")
                    Spacer()
                    Text(marketItem?.totalVolume?.formatCurrencyAbreviation(currencyCode: dataProvider.currencyCode) ?? "")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Available Supply")
                    Spacer()
                    Text((marketItem?.circulatingSupply?.formatted(.number) ?? "") + " " + (marketItem?.symbol.uppercased() ?? ""))
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Total Supply")
                    Spacer()
                    Text((marketItem?.totalSupply?.formatted(.number) ?? "") + " " + (marketItem?.symbol.uppercased() ?? ""))
                        .foregroundColor(.secondary)
                }
            }

        }
        .padding()
        .background(Material.ultraThinMaterial)
        .cornerRadius(8)
    }
    
    func load(marketItemId: String) async {

        loading = true
        
        var days = 1
        switch chartSegment {
        case 0:
            days = 1
            percentageChange = .percentage24h
        case 1:
            days = 7
            percentageChange = .percentage7d
        case 2:
            days = 30
            percentageChange = .percentage30d
        case 3:
            days = 200
            percentageChange = .percentage200d
        case 4:
            days = 360
            percentageChange = .percentage1y
        default:
            days = 1
        }

        marketItemChartPrices = try? await CoinGecko.V3.Coins.MarketChart.get(byId: marketItemId,
                                                                              vsCurrency: dataProvider.currencyCode,
                                                                              days: "\(days)", interval: "")

        marketItemDetail = try? await CoinGecko.V3.Coins.get(byId: marketItemId)

        chartYData = marketItemChartPrices?.flattendPrices() ?? []
        
        loading = false
        
    }
    
    func priceIsUp() -> Bool {
        return marketItem?.isUp(inPriceChangePeriod: self.percentageChange) ?? false
    }
    
    func chartIsUp() -> Bool {
        guard let prices = marketItemChartPrices?.flattendPrices() else { return false }
        guard let first = prices.first else { return false }
        guard let last = prices.last else { return false }
        return last > first
    }
    
}

struct ListMarketItemDetailView_Previews: PreviewProvider {
    static let dataProvider = DataProvider()
    static var previews: some View {
        ListMarketItemDetailView(marketItemId: "bitcoin")
            .environmentObject(dataProvider)
    }
}
