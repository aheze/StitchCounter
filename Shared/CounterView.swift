//
//  CounterView.swift
//  StitchCounter
//
//  Created by Zheng on 9/6/21.
//

import SwiftUI

struct CounterView: View {
    @State var input = ""
    @State var results = [Result]()
    @State var countPressedOnce = false
    @Binding var regex: String
    
    var body: some View {
        ZStack {
            
            #if os(iOS)
            Color(UIColor.secondarySystemBackground)
            #endif
            
            VStack(spacing: 12) {
                HStack {
                    Text("Enter Pattern")
                        .font(.system(size: 17, weight: .medium))
                    
                    Spacer()
                }
                
                TextEditor(text: $input)
                    .font(.system(size: 21, weight: .medium))
                    .frame(maxHeight: results.count > 0 ? 100 : .infinity)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 0))
                    .background(Color("Background"))
                    .cornerRadius(16)
                    .overlay(
                        Group {
                            if input.isEmpty {
                                #if os(macOS)
                                Text("Enter your pattern here")
                                    .font(.system(size: 21, weight: .bold))
                                    .opacity(0.25)
                                    .padding(EdgeInsets(top: 16, leading: 24, bottom: 0, trailing: 0))
                                #else
                                Text("Enter your pattern here")
                                    .font(.system(size: 21, weight: .bold))
                                    .opacity(0.25)
                                    .padding(EdgeInsets(top: 24, leading: 24, bottom: 0, trailing: 0))
                                #endif
                            }
                        }, alignment: .topLeading
                    )
                
                if results.count > 0 {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Total number of stitches:")
                                .font(.system(size: 17, weight: .medium))
                            
                            Spacer()
                            
                            Button(action: {
                                
                                #if os(macOS)
                                let pasteboard = NSPasteboard.general
                                pasteboard.declareTypes([.string], owner: nil)
                                pasteboard.setString("\(getTotal(from: results))", forType: .string)
                                
                                #else
                                
                                UIPasteboard.general.string = "Hello world"
                                
                                #endif
                                
                            }) {
                                Text("\(getTotal(from: results))")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color.accentColor)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        ScrollView {
                            VStack {
                                ForEach(results) { result in
                                    HStack {
                                        if let groupMultiplier = result.groupMultiplier {
                                            HStack {
                                                Text(result.pattern)
                                                    .padding(6)
                                                    .background(Color("Background"))
                                                    .cornerRadius(6)
                                                
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 12, weight: .regular))
                                                
                                                Text("\(groupMultiplier)")
                                            }
                                            .font(.system(size: 17, weight: .regular))
                                        } else {
                                            Text(result.pattern)
                                                .font(.system(size: 17, weight: .regular))
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(result.count)")
                                            .font(.system(size: 17, weight: .regular))
                                    }
                                    .padding(10)
                                    .background(Color("SecondaryBackground"))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(16)
                        }
                        .background(Color("Background"))
                        .cornerRadius(16)
                    }
                } else {
                    if countPressedOnce {
                        Text("Enter a valid pattern")
                            .font(.system(size: 17, weight: .medium))
                            .opacity(0.5)
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .onChange(of: regex) { _ in
            count()
        }
        .toolbar {
            #if os(iOS)
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                toolbar
            }
            #else
            ToolbarItemGroup(placement: .primaryAction) {
                toolbar
            }
            #endif
        }
    }
    
    var toolbar: some View {
        Group {
            if !input.isEmpty {
                Button(action: {
                    input = ""
                    count()
                    withAnimation {
                        countPressedOnce = false
                    }
                }) {
                    #if os(macOS)
                    Text("Clear")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(Color("Destructive"))
                        .cornerRadius(8)
                    
                    #else
                    Text("Clear")
                    #endif
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button(action: {
                count()
                withAnimation {
                    countPressedOnce = true
                }
            }) {
                #if os(macOS)
                Text("Count")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.white)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(Color.accentColor)
                    .cornerRadius(8)
                #else
                Text("Count")
                #endif
            }
            .buttonStyle(PlainButtonStyle())
            .allowsTightening(!input.isEmpty)
            .opacity(input.isEmpty ? 0.75 : 1)
        }
    }
    
    func count() {
        
        var results = [Result]()
        
        /// support grouping
        let extractedGroups = matchRegex(stringToCheck: input, regex: Constants.groupRegex)
        
        for group in extractedGroups {
            let contents = extractStitchText(group: group, name: "contents", in: input)
            let groupMultiplierString = extractStitchText(group: group, name: "groupMultiplier", in: input)
            let groupMultiplier = Int(groupMultiplierString) ?? 1
            
            let groupResults = countStitchesIn(string: contents)
            
            let totalCount = getTotal(from: groupResults) * (groupMultiplier)
            let combinedResult = Result(pattern: contents, count: totalCount, groupMultiplier: groupMultiplier)
            results.append(combinedResult)
        }
        
        let ungroupedInput = input.replacingOccurrences(of: Constants.groupRegex, with: "", options: .regularExpression, range: nil)
        let ungroupedResults = countStitchesIn(string: ungroupedInput)
        results += ungroupedResults
        
        withAnimation {
            self.results = results
        }
        
    }
    
    func countStitchesIn(string: String) -> [Result] {
        var stitches = [Stitch]()
        var results = [Result]()
        
        let matchedSubstrings = matchRegex(stringToCheck: string, regex: regex)
        for substring in matchedSubstrings {
            let contentsValueOne = extractStitchText(group: substring, name: "count1", in: string)
            let contentsValueTwo = extractStitchText(group: substring, name: "count2", in: string)
            let contentsValueThree = extractStitchText(group: substring, name: "count3", in: string)
            
            
            if !contentsValueOne.isEmpty {
                let match = Stitch(name: contentsValueOne, count: 1)
                stitches.append(match)
            } else if !contentsValueTwo.isEmpty {
                let match = Stitch(name: contentsValueTwo, count: 2)
                stitches.append(match)
            } else {
                let match = Stitch(name: contentsValueThree, count: 3)
                stitches.append(match)
            }
        }
        
        for stitch in stitches {
            let matchedSubstring = stitch.name
            
            var multipliers = [Int]()
            let countStitches = matchRegex(stringToCheck: matchedSubstring, regex: Constants.multiplierRegex)
            for countStitch in countStitches {
                if let substringRange = Range(countStitch.range, in: matchedSubstring) {
                    let countString = String(matchedSubstring[substringRange])
                    multipliers.append(Int(countString) ?? 1)
                }
            }
            if multipliers.count > 0 {
                let numberOfStitches = stitch.count * multipliers.reduce(1, *)
                let result = Result(pattern: matchedSubstring, count: numberOfStitches)
                results.append(result)
            } else {
                let numberOfStitches = stitch.count
                let result = Result(pattern: matchedSubstring, count: numberOfStitches)
                results.append(result)
            }
        }
        
        return results
    }
    
    func getTotal(from results: [Result]) -> Int {
        let totalCount = results.reduce(0) { $0 + $1.count }
        return totalCount
    }
    
    func matchRegex(stringToCheck: String, regex: String) -> [NSTextCheckingResult] {
        let inputRange = NSRange(
            stringToCheck.startIndex..<stringToCheck.endIndex,
            in: stringToCheck
        )
        
        let inputRegex = try! NSRegularExpression(
            pattern: regex,
            options: []
        )
        
        let stitches = inputRegex.matches(
            in: stringToCheck,
            options: [],
            range: inputRange
        )
        
        return stitches
    }
    
    func extractStitchText(group: NSTextCheckingResult, name: String, in fullString: String) -> String {
        let matchRange = group.range(withName: name)
        
        /// Extract the substring that matches the named capture group
        if let substringRange = Range(matchRange, in: fullString) {
            let matchedSubstring = String(fullString[substringRange])
            return matchedSubstring
        }
        return ""
    }
}
