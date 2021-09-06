//
//  SettingsView.swift
//  StitchCounter
//
//  Created by Zheng on 9/6/21.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("stitchesText") var stitchesText: String = "(?<count1>([0-9])*(inc|dec|sc|sl st|hdc|dc|tr|fsc|sc[0-9]tog)( {1}[0-9]+)?)"
    @Binding var regex: String
    @State var stitches = [Stitch]()
    
    var body: some View {
        
        VStack(alignment: .trailing, spacing: 16) {
            
            HStack(alignment: .bottom) {
                
                Text("Enter stitches:")
                    .font(.system(size: 17, weight: .medium))
                
                Spacer()
                
                Button(action: {
                    saveToAppStorage()
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
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(stitches) { stitch in
                        if let stitchIndex = stitches.firstIndex(where: { $0.id == stitch.id }) {
                            HStack {
                                HStack {
                                    TextField("Stitch name", text: Binding(get: { stitches[stitchIndex].name }, set: { stitches[stitchIndex].name = $0 }))
                                        .textFieldStyle(PlainTextFieldStyle())
                                    
                                    TextField("Count", value: Binding(get: { stitches[stitchIndex].count }, set: { stitches[stitchIndex].count = $0 }), formatter: NumberFormatter())
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .multilineTextAlignment(.trailing)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                
                                Button(action: {
                                    print("removing: \(stitchIndex)")
                                    stitches.remove(at: stitchIndex)
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    Button(action: {
                        let newStitch = Stitch(name: "", count: 1)
                        stitches.append(newStitch)
                    }) {
                        Text("Add")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
        }
        .onAppear {
            readAppStorage()
        }
    }
    
    func readAppStorage() {
        let stitches = Storage.readStitchesString(string: stitchesText)
        self.stitches = stitches
    }
    
    func saveToAppStorage() {
        let text = Storage.buildStitchesString(stitches: stitches)
        stitchesText = text
        regex = RegexBuilder.buildRegex(stitches: stitches)
    }
}
