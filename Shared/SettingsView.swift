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
        
        VStack(alignment: .trailing, spacing: 16) {
            
            HStack(alignment: .bottom) {
                
                Text("Enter stitches:")
                    .font(.system(size: 17, weight: .medium))
                
                Spacer()
                
                Button(action: {
                    stitchesText = settings.getStitchesText()
                    settings.readAppStorage(stitchesText: stitchesText)
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .medium))
                        .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack(spacing: 12) {
                ForEach(settings.stitches) { stitch in
                    if let stitchIndex = settings.stitches.firstIndex(where: { $0.id == stitch.id }) {
                        HStack {
                            HStack {
                                TextField("Stitch name", text: Binding(get: { settings.stitches[stitchIndex].name }, set: { settings.stitches[stitchIndex].name = $0 }))
                                    .font(.system(size: 17, weight: .medium))
                                    .textFieldStyle(PlainTextFieldStyle())
                                
                                TextField("Count", value: Binding(get: { settings.stitches[stitchIndex].count }, set: { settings.stitches[stitchIndex].count = $0 }), formatter: NumberFormatter())
                                    .font(.system(size: 17, weight: .bold))
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding()
                            .background(Color.white)
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
                
                
                Button(action: {
                    let newStitch = Stitch(name: "", count: 1)
                    withAnimation {
                        settings.stitches.append(newStitch)
                    }
                }) {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .animation(.default, value: settings.stitches)
            .frame(maxWidth: .infinity)
            
            Spacer()
            
        }
        .padding(.horizontal)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        settings.stitches.move(fromOffsets: source, toOffset: destination)
    }
    
    
}
//extension NSTableView {
//    open override func viewDidMoveToWindow() {
//        super.viewDidMoveToWindow()
//
//        backgroundColor = NSColor.clear
//        enclosingScrollView!.drawsBackground = false
//    }
//}
