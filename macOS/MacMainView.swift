//
//  MacMainView.swift
//  CoinvisionTV (macOS)
//
//  Created by Jacob Davis on 11/3/21.
//

import SwiftUI

struct MacMainView: View {
    
    @EnvironmentObject var dataProvider: DataProvider
    @State private var listViewActive = true
    @State private var tilesViewActive = false
    @State private var bubblesViewActive = false
    
    var body: some View {
        
        if listViewActive || tilesViewActive {
            
            NavigationView {
                
                SidebarView(listViewActive: $listViewActive, tilesViewActive: $tilesViewActive,
                            bubblesViewActive: $bubblesViewActive)
                    .frame(minWidth: 200)
                    .toolbar {
                        Button(action: toggleSidebar) {
                            Image(systemName: "sidebar.left")
                                .help("Toggle Sidebar")
                            }
                        }
                
                
                EmptyView()
                
                VStack(spacing: 16) {
                    Image(systemName: "filemenu.and.cursorarrow")
                        .font(.system(size: 42))
                    Text("Select a coin for more detailed information.")
                        .font(.title3)
                }
                .foregroundColor(.secondary)
                .padding()
                .background(Material.thick)
                .cornerRadius(8)
                .frame(minWidth: 450, idealWidth: 600)

            }
            .navigationTitle("Coinvision TV")
            .navigationViewStyle(.columns)
            
        } else {
            
            NavigationView {
                
                SidebarView(listViewActive: $listViewActive, tilesViewActive: $tilesViewActive,
                            bubblesViewActive: $bubblesViewActive)
                    .frame(minWidth: 200)
                    .toolbar {
                        Button(action: toggleSidebar) {
                            Image(systemName: "sidebar.left")
                                .help("Toggle Sidebar")
                            }
                        }

            }
            .navigationTitle("Coinvision TV")
            .navigationViewStyle(.columns)
            
        }

    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?
            .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}


struct SidebarView: View {
    
    @Binding var listViewActive: Bool
    @Binding var tilesViewActive: Bool
    @Binding var bubblesViewActive: Bool
    @EnvironmentObject var dataProvider: DataProvider
    
    var body: some View {
        
        List {
            
            Section("Menu") {
                NavigationLink(destination: ListView(),
                               isActive: $listViewActive,
                               label: {
                    Label("List", systemImage: "list.bullet.rectangle.fill")
                })
                
                NavigationLink(destination: TilesView(),
                               isActive: $tilesViewActive,
                               label: {
                    Label("Tiles", systemImage: "square.grid.3x2.fill")
                })
                
                NavigationLink(destination: BubblesView(),
                               isActive: $bubblesViewActive,
                               label: {
                    Label("Bubbles", systemImage: "circle.hexagongrid.fill")
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
