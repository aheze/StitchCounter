//
//  SettingsView.swift
//  StitchCounter
//
//  Created by Zheng on 9/6/21.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var settings: Settings
    @Binding var stitchesText: String
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            HStack {
                Text("Stitches / Count")
                    .font(.system(size: 17, weight: .medium))
                
                Spacer()
            }
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(settings.stitches) { stitch in
                        if let stitchIndex = settings.stitches.firstIndex(where: { $0.id == stitch.id }) {
                            HStack {
                                HStack {
                                    TextField(
                                        "Stitch name",
                                        text: Binding(
                                            get: { settings.stitches[safe: stitchIndex]?.name ?? ""},
                                            set: { settings.stitches[stitchIndex].name = $0 }
                                        )
                                    )
                                    .font(.system(size: 17, weight: .medium))
                                    .textFieldStyle(PlainTextFieldStyle())
                                    
                                    Picker("",
                                           selection: Binding(
                                            get: { settings.stitches[safe: stitchIndex]?.count ?? 1},
                                            set: { settings.stitches[stitchIndex].count = $0 }
                                           )
                                    ) {
                                        ForEach(1...3, id: \.self) {
                                            Text("\($0)")
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    
                                }
                                .padding()
                                .background(Color("Background"))
                                .cornerRadius(8)
                                
                                Button(action: {
                                    settings.stitches.remove(at: stitchIndex)
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 15, weight: .medium))
                                        .frame(width: 40)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            let newStitch = Stitch(name: "", count: 1)
                            withAnimation {
                                settings.stitches.append(newStitch)
                            }
                        }) {
                            Text("Add")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("SecondaryBackground"))
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Rectangle()
                            .opacity(0)
                            .frame(width: 40)
                    }
                }
            }
        }
        .padding()
        .animation(.default, value: settings.stitches)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    stitchesText = settings.getStitchesText()
                    settings.readAppStorage(stitchesText: stitchesText)
                }) {
                    Text("Save")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        settings.stitches.move(fromOffsets: source, toOffset: destination)
    }   
}
