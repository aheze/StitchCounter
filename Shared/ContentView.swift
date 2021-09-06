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
    
    var body: some View {
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
        .frame(minWidth: 400, idealWidth: 400, maxWidth: 700, minHeight: 300, idealHeight: 300, maxHeight: 800)
    }
}

