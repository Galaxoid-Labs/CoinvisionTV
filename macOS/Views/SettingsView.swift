//
//  SettingsView.swift
//  CoinvisionTV (macOS)
//
//  Created by Jacob Davis on 11/5/21.
//

import SwiftUI
import CoinGecko

struct SettingsView: View {
    
    @State private var d = false
    @EnvironmentObject var dataProvider: DataProvider
    @AppStorage("hideStableCoins") var hideStableCoins: Bool = true
    
    var body: some View {
        
        VStack {
            List {
                Section("Appearance") {
                    
                    Button(action: { dataProvider.colorTheme = .dark }) {
                        HStack {
                            Label("Dark", systemImage: "moon.fill")
                            Spacer()
                            if dataProvider.colorTheme == .dark {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .padding(8)
                    .background(Material.thin)
                    .cornerRadius(4)
                    
                    Button(action: { dataProvider.colorTheme = .light }) {
                        HStack {
                            Label("Light", systemImage: "moon")
                            Spacer()
                            if dataProvider.colorTheme == .light {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .padding(8)
                    .background(Material.thin)
                    .cornerRadius(4)
                    
                }
                .buttonStyle(.plain)
                
                Section("Filters") {
                    Toggle(isOn: $hideStableCoins) {
                        Text("Hide Stable Coins")
                    }
                }
                
                Section("Currency") {
                    
                    Picker("", selection: dataProvider.$currencyCode) {
                        ForEach(CoinGecko.currencyCodes, id: \.self) {
                            Text($0.uppercased())
                        }
                    }
                    
                }
            }
            .listStyle(.inset)
        }
        .frame(width: 300, height: 210)
        .navigationTitle("Coinvision TV Preferences")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let dataProvider = DataProvider()
    static var previews: some View {
        SettingsView()
            .environmentObject(dataProvider)
            .task {
                await dataProvider.fetchAndSetMarketItems()
            }
    }
}
