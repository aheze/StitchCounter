//
//  ContentView.swift
//  Shared
//
//  Created by Zheng on 9/6/21.
//

import SwiftUI

struct ContentView: View {
    @State var regex = ""
    var body: some View {
        TabView {
            CounterView(regex: $regex)
                .tabItem {
                    Label("Counter", systemImage: "number")
                }
            
            SettingsView(regex: $regex)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .frame(minWidth: 400, idealWidth: 400, maxWidth: 700, minHeight: 300, idealHeight: 300, maxHeight: 800)
    }
}
