//
//  ContentView.swift
//  Shared
//
//  Created by Zheng on 9/6/21.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("stitchesText") var stitchesText: String = "inc=2,sc=1,sc[0-9]tog=1,dec=2,sl st=1,hdc=1,dc=1,fsc=1"
    @StateObject var settings = Settings()
    @State var selectedTab: Int? = 0
    
    var body: some View {
        #if os(macOS)
        NavigationView {
            List(selection: $selectedTab) {
                
                NavigationLink(destination: CounterView(regex: $settings.regex), tag: 0, selection: $selectedTab) {
                    Label("Counter", systemImage: "number")
                        .font(.system(size: 17, weight: .medium))
                        .accentColor(Color("AccentColor"))
                        .accentColor(Color.accentColor)
                }
                .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))

                
                NavigationLink(destination: SettingsView(settings: settings, stitchesText: $stitchesText), tag: 1, selection: $selectedTab) {
                    Label("Settings", systemImage: "gearshape")
                        .font(.system(size: 17, weight: .medium))
                        .accentColor(Color("AccentColor"))
                        .accentColor(Color.accentColor)
                }
                .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
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
            print("apear!")
            settings.readAppStorage(stitchesText: stitchesText)
            stitchesText = settings.getStitchesText()
        }
        
        #else
        TabView {
            NavigationView {
                CounterView(regex: $settings.regex)
                    .navigationTitle("Counter")
            }
            .tabItem {
                Label("Counter", systemImage: "number")
            }
            
            NavigationView {
                SettingsView(settings: settings, stitchesText: $stitchesText)
                    .navigationTitle("Settings")
            }
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

