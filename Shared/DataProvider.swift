//
//  DataProvider.swift
//  CryptoTV
//
//  Created by Jacob Davis on 10/27/21.
//

import Foundation
import SwiftUI
import CoinGecko
import EasyStash

typealias MarketItem = CoinGecko.V3.Coins.Markets.ResponseItem
typealias CoinId = CoinGecko.V3.Coins.List.ResponseItem
typealias MarketItemChart = CoinGecko.V3.Coins.MarketChart.Response
typealias MarketItemDetail = CoinGecko.V3.Coins.Response

class DataProvider: ObservableObject {
    
    @Published var marketItems = [MarketItem]()
    @Published var coinIds = [CoinId]()
    @Published var languageCode = "en"
    
    @AppStorage("currencyCode") var currencyCode: String = "usd" {
        didSet {
            Task {
                await self.fetchAndSetMarketItems()
                self.setupPollingTimer()
            }
        }
    }
    @AppStorage("marketsOrder") var marketsOrder: CoinGecko.V3.Coins.Markets.Order = .market_cap_desc {
        didSet {
            Task {
                await self.fetchAndSetMarketItems()
                self.setupPollingTimer()
            }
        }
    }
    
    private var storage: Storage?
    private var pollingTimer: Timer?
    
    init() {
        
        var options = Options()
        options.folder = "storage"
        
        do {
            storage = try Storage(options: options)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        setupPollingTimer()
        
    }
    
    func setupPollingTimer() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { timer in
            Task {
                await self.fetchAndSetMarketItems()
            }
        })
    }
    
    @MainActor
    func loadAll() {
        
        guard let storage = self.storage else {
            fatalError("Unable to unwrap storage")
        }

        if let marketItems = try? storage.load(forKey: "marketItems", as: [MarketItem].self) {
            self.marketItems = marketItems
        }
        
        if let coinIds = try? storage.load(forKey: "coinIds", as: [CoinId].self) {
            self.coinIds = coinIds
        }
        
    }
    
    @MainActor
    func saveAll() {
        
        guard let storage = self.storage else {
            fatalError("Unable to unwrap storage")
        }

        do {
            try storage.save(object: self.marketItems, forKey: "marketItems")
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try storage.save(object: self.coinIds, forKey: "coinIds")
        } catch {
            print(error.localizedDescription)
        }

    }
    
    @MainActor
    func fetchAndSetCoinList() async {
        
        if let coinIds = try? await CoinGecko.V3.Coins.List.get() {
            self.coinIds = coinIds
        }
        
    }
    
    @MainActor
    func fetchAndSetMarketItems() async {
        if let marketItems = try? await CoinGecko.V3.Coins.Markets.get(vsCurrency: currencyCode, order: marketsOrder) {
            self.marketItems = marketItems
        }
    }
    
    func overallMarket() -> Double {
        return marketItems.map({ $0.priceChangePercentage24H ?? .zero }).reduce(Double.zero, +)
    }
    
}

