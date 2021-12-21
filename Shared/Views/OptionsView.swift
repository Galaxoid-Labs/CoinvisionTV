//
//  OptionsView.swift
//  CoinvisionTV
//
//  Created by Jacob Davis on 11/1/21.
//

import SwiftUI
import CoinGecko

enum ColorTheme: String {
    case light, dark
}

struct OptionsView: View {
    
    @EnvironmentObject var dataProvider: DataProvider
    
    @State private var menuLabel: String = ""
    @State private var menuItemImageName: String = "gearshape"
    @State private var needsBack: Bool = false
    @AppStorage("colorTheme") var colorTheme: ColorTheme = ColorTheme.dark
    @AppStorage("hideStableCoins") var hideStableCoins: Bool = true
    
    var body: some View {
        
        HStack {
            
            LazyVStack {
                
                Spacer()

                VStack {
                    Text(menuLabel)
                        .font(.title3)
                    Image(systemName: menuItemImageName)
                        .font(.system(size: 96))
                        .foregroundColor(.secondary)
                        .frame(width: 100, height: 100, alignment: .center)
                }
                .padding(64)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(16)
                .animation(.easeIn, value: true)
                
                Spacer(minLength: 300)
                
                if !needsBack {
                    Text("Please contact **support@galaxoidlabs.com** if you have any suggestions or bug related requests.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                if needsBack {
                    Text("Press the **Menu** button on the remote to go back")
                }

            }
            
            NavigationView {
                List {
                    NavigationLink(destination: {
                        List {
                            Button(action: { dataProvider.marketsOrder = .market_cap_desc }) {
                                HStack {
                                    Text("Market Cap ↓")
                                    Spacer()
                                    if dataProvider.marketsOrder == .market_cap_desc {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                            Button(action: { dataProvider.marketsOrder = .market_cap_asc }) {
                                HStack {
                                    Text("Market Cap ↑")
                                    Spacer()
                                    if dataProvider.marketsOrder == .market_cap_asc {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                            Button(action: { dataProvider.marketsOrder = .volume_desc }) {
                                HStack {
                                    Text("Volume ↓")
                                    Spacer()
                                    if dataProvider.marketsOrder == .volume_desc {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                            Button(action: { dataProvider.marketsOrder = .volume_asc }) {
                                HStack {
                                    Text("Volume ↑")
                                    Spacer()
                                    if dataProvider.marketsOrder == .volume_asc {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                            Button(action: { dataProvider.marketsOrder = .gecko_desc }) {
                                HStack {
                                    Text("Coingecko Rating ↓")
                                    Spacer()
                                    if dataProvider.marketsOrder == .gecko_desc {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                            Button(action: { dataProvider.marketsOrder = .gecko_asc }) {
                                HStack {
                                    Text("Coingecko Rating ↑")
                                    Spacer()
                                    if dataProvider.marketsOrder == .gecko_asc {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                        }
                        .padding(.leading, 64)
                        #if os(tvOS) || os(iOS)
                        .listStyle(GroupedListStyle())
                        #endif
                        .onAppear {
                            withAnimation {
                                self.menuLabel = "Ordering"
                                self.menuItemImageName = "arrow.up.arrow.down.circle.fill"
                                self.needsBack = true
                            }
                        }
                        .onDisappear {
                            self.resetMenu()
                        }
                    }, label: {
                        HStack(spacing: 0) {
                            Text("Ordering")
                            Spacer()
                            Text(getOrderingLabel())
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                                .offset(x: 50, y: 0)
                        }
                    })
                    
                    NavigationLink(destination: {
                        List {
                            
                            ForEach(CoinGecko.currencyCodes, id: \.self) { code in
                                
                                Button(action: { dataProvider.currencyCode = code }) {
                                    HStack {
                                        Text(code.uppercased())
                                        Spacer()
                                        if dataProvider.currencyCode == code {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                        .padding(.leading, 64)
                        #if os(tvOS) || os(iOS)
                        .listStyle(GroupedListStyle())
                        #endif
                        .onAppear {
                            withAnimation {
                                self.menuLabel = "Currency"
                                self.menuItemImageName = "dollarsign.circle.fill"
                                self.needsBack = true
                            }
                        }
                        .onDisappear {
                            self.resetMenu()
                        }
                    }, label: {
                        HStack(spacing: 0) {
                            Text("Currency")
                            Spacer()
                            Text(dataProvider.currencyCode.uppercased())
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                                .offset(x: 50, y: 0)
                        }
                    })
                    
                    NavigationLink(destination: {
                        List {
                            Button(action: {
                                hideStableCoins = true
                                self.menuItemImageName = "eye.slash"
                            }) {
                                HStack {
                                    Text("Yes")
                                    Spacer()
                                    if hideStableCoins == true {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                            Button(action: {
                                hideStableCoins = false
                                self.menuItemImageName = "eye"
                            }) {
                                HStack {
                                    Text("No")
                                    Spacer()
                                    if hideStableCoins == false {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                        }
                        .padding(.leading, 64)
                        #if os(tvOS) || os(iOS)
                        .listStyle(GroupedListStyle())
                        #endif
                        .onAppear {
                            withAnimation {
                                self.menuLabel = "Hide Stable Coins"
                                self.menuItemImageName = hideStableCoins == true ? "eye.slash" : "eye"
                                self.needsBack = true
                            }
                        }
                        .onDisappear {
                            self.resetMenu()
                        }
                    }, label: {
                        HStack(spacing: 0) {
                            Text("Hide Stable Coins")
                            Spacer()
                            Text(hideStableCoins == true ? "Yes" : "No")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                                .offset(x: 50, y: 0)
                        }
                    })
                    
                    NavigationLink(destination: {
                        List {
                            Button(action: { colorTheme = ColorTheme.dark }) {
                                HStack {
                                    Text("Dark")
                                    Spacer()
                                    if colorTheme == ColorTheme.dark {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                            Button(action: { colorTheme = ColorTheme.light }) {
                                HStack {
                                    Text("Light")
                                    Spacer()
                                    if colorTheme == ColorTheme.light {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                        }
                        .padding(.leading, 64)
                        #if os(tvOS) || os(iOS)
                        .listStyle(GroupedListStyle())
                        #endif
                        .onAppear {
                            withAnimation {
                                self.menuLabel = "Appearance"
                                self.menuItemImageName = "moon.fill"
                                self.needsBack = true
                            }
                        }
                        .onDisappear {
                            self.resetMenu()
                        }
                    }, label: {
                        HStack(spacing: 0) {
                            Text("Appearance")
                            Spacer()
                            Text(colorTheme == ColorTheme.dark ? "Dark" : "Light")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                                .offset(x: 50, y: 0)
                        }
                    })

                }
                #if os(tvOS) || os(iOS)
                .listStyle(GroupedListStyle())
                #endif
                .padding(.leading, 64)
                
            }
            
        }

    }
    
    func resetMenu() {
        withAnimation {
            self.menuLabel = ""
            self.menuItemImageName = "gearshape"
            self.needsBack = false
        }
    }
    
    func getOrderingLabel() -> String {
        switch dataProvider.marketsOrder {
        case .market_cap_desc:
            return "Market Cap ↓"
        case .market_cap_asc:
            return "Market Cap ↑"
        case .volume_desc:
            return "Volume ↓"
        case .volume_asc:
            return "Volume ↑"
        case .gecko_desc:
            return "Coingecko Rating ↓"
        case .gecko_asc:
            return "Coingecko Rating ↑"
        default:
            return "Market Cap"
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static let dataProvider = DataProvider()
    static var previews: some View {
        OptionsView()
            .environmentObject(dataProvider)
            .task {
                await dataProvider.fetchAndSetMarketItems()
            }
    }
}
