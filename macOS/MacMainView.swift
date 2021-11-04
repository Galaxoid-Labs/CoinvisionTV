//
//  MacMainView.swift
//  CoinvisionTV (macOS)
//
//  Created by Jacob Davis on 11/3/21.
//

import SwiftUI

struct MacMainView: View {
    
    @EnvironmentObject var dataProvider: DataProvider
    @State private var selectedMarketItem: MarketItem? = nil
    
    var body: some View {
        
        NavigationView {
            
            SidebarView(selectedMarketItem: $selectedMarketItem)
                .frame(minWidth: 200)
                .toolbar {
                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.left")
                            .help("Toggle Sidebar")
                        }
                    }

            Text("Placeholder")
            if selectedMarketItem != nil {
                ListMarketItemDetailView(marketItem: $selectedMarketItem)
            } else {
                VStack {
                    Text("Select a coin from the list for more information.")
                        .font(.title3)
                }
                .padding()
                .background(Material.thick)
                .cornerRadius(8)
            }
            
        }
        .navigationTitle("Coinvision TV")
        .navigationViewStyle(.columns)

    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?
            .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}


struct SidebarView: View {
    
    @State private var isDefaultItemActive = true
    @Binding var selectedMarketItem: MarketItem?
    @EnvironmentObject var dataProvider: DataProvider
    
    var body: some View {
        
        List {
            
            Section("Menu") {
                NavigationLink(destination: ListView(selectedMarketItem: $selectedMarketItem),
                               isActive: $isDefaultItemActive,
                               label: {
                    Label("List", systemImage: "list.bullet.rectangle.fill")
                })
                
                NavigationLink(destination: TilesView(selectedMarketItem: $selectedMarketItem),
                               label: {
                    Label("Tiles", systemImage: "square.grid.3x2.fill")
                })
                
                NavigationLink(destination: BubblesView(),
                               label: {
                    Label("Bubbles", systemImage: "circle.hexagongrid.fill")
                })
                
                NavigationLink(destination: OptionsView(),
                               label: {
                    Label("Options", systemImage: "gearshape")
                })
            }
            
        }
        .listStyle(SidebarListStyle())
        
    }
    
}

struct MacMainView_Previews: PreviewProvider {
    static let dataProvider = DataProvider()
    static var previews: some View {
        MacMainView()
            .environmentObject(dataProvider)
    }
}
