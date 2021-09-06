//
//  ContentView.swift
//  Shared
//
//  Created by Zheng on 9/6/21.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("stitchesText") var stitchesText: String = "inc=2,sc=1"
    @StateObject var settings = Settings()
    @State var selectedTab: Int? = 0
    
    var body: some View {
        #if os(macOS)
        NavigationView {
            List(selection: $selectedTab) {
                NavigationLink(destination: CounterView(regex: $settings.regex)) {
                    Label("Counter", systemImage: "number")
                        .font(.system(size: 17, weight: .medium))
                        .accentColor(Color("AccentColor"))
                        .accentColor(Color.accentColor)
                }
                .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                .tag(0)
                
                NavigationLink(destination: SettingsView(settings: settings, stitchesText: $stitchesText)) {
                    Label("Settings", systemImage: "gearshape")
                        .font(.system(size: 17, weight: .medium))
                        .accentColor(Color("AccentColor"))
                        .accentColor(Color.accentColor)
                }
                .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                .tag(1)
            }
            
            .listStyle(SidebarListStyle())
            .navigationTitle("StitchCounter")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: { // 1
                        Image(systemName: "sidebar.leading")
                    })
                }
            }
        }
        .frame(minWidth: 500, idealWidth: 500, maxWidth: 700, minHeight: 300, idealHeight: 600, maxHeight: 800)
        .onAppear {
            settings.readAppStorage(stitchesText: stitchesText)
            stitchesText = settings.getStitchesText()
        }
        
        #else
        TabView {
            CounterView(regex: $settings.regex)
                .tabItem {
                    Label("Counter", systemImage: "number")
                }
            
            SettingsView(settings: settings, stitchesText: $stitchesText)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            settings.readAppStorage(stitchesText: stitchesText)
            stitchesText = settings.getStitchesText()
        }
        #endif
        
    }
    
    private func toggleSidebar() { // 2
            #if os(iOS)
            #else
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
            #endif
        }
}

