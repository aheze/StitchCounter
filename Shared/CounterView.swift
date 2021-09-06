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
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack(alignment: .bottom) {
                    Text("Enter pattern:")
                        .font(.system(size: 17, weight: .medium))
                    
                    Spacer()
                    
                    Button(action: {
                        input = ""
                        count()
                        countPressedOnce = false
                    }) {
                        Text("Clear")
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .background(Color.red)
                            .cornerRadius(8)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        count()
                        countPressedOnce = true
                    }) {
                        Text("Count")
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .background(Color.blue)
                            .cornerRadius(8)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                HStack {
                    TextEditor(text: $input)
                        .font(.system(size: 21, weight: .medium))
                        .frame(maxHeight: results.count > 0 ? 100 : .infinity)
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 0))
                        .background(Color.white)
                        .cornerRadius(16)
                }
            }
            
            if results.count > 0 {
                VStack(spacing: 8) {
                    HStack {
                        Text("Total number of stitches:")
                            .font(.system(size: 17, weight: .medium))
                        
                        Spacer()
                        
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.declareTypes([.string], owner: nil)
                            pasteboard.setString("\(getTotal(from: results))", forType: .string)
                        }) {
                            Text("\(getTotal(from: results))")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(#colorLiteral(red: 0.2526637316, green: 0.7980186343, blue: 0.9190346003, alpha: 1)))
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
                                                .background(Color.white)
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
                                .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)))
                                .cornerRadius(8)
                            }
                        }
                        .padding(16)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                }
            } else {
                if countPressedOnce {
                    Text("Enter a valid pattern")
                }
                Spacer()
            }
        }
        .onChange(of: regex) { _ in
            count()
        }
        .padding()
    }
    
    
    func count() {
        
        var results = [Result]()
        
        /// support grouping
        let extractedGroups = matchRegex(stringToCheck: input, regex: Constants.groupRegex)
        
        for group in extractedGroups {
            let contents = extractMatchText(group: group, name: "contents", in: input)
            let groupMultiplierString = extractMatchText(group: group, name: "groupMultiplier", in: input)
            let groupMultiplier = Int(groupMultiplierString) ?? 1
            
            let groupResults = countMatchesIn(string: contents)
            
            let totalCount = getTotal(from: groupResults) * (groupMultiplier)
            let combinedResult = Result(pattern: contents, count: totalCount, groupMultiplier: groupMultiplier)
            results.append(combinedResult)
        }
        
        let ungroupedInput = input.replacingOccurrences(of: Constants.groupRegex, with: "", options: .regularExpression, range: nil)
        let ungroupedResults = countMatchesIn(string: ungroupedInput)
        results += ungroupedResults
        
        withAnimation {
            self.results = results
        }
   
    }
    
    func countMatchesIn(string: String) -> [Result] {
        var matches = [Match]()
        var results = [Result]()
        
        let matchedSubstrings = matchRegex(stringToCheck: string, regex: regex)
        for substring in matchedSubstrings {
            let contentsValueOne = extractMatchText(group: substring, name: "one", in: string)
            let contentsValueTwo = extractMatchText(group: substring, name: "two", in: string)
            
            if !contentsValueOne.isEmpty {
                let match = Match(text: contentsValueOne, multiplier: 1)
                matches.append(match)
            } else {
                let match = Match(text: contentsValueTwo, multiplier: 2)
                matches.append(match)
            }
        }
        
        for match in matches {
            let matchedSubstring = match.text
            
            var multipliers = [Int]()
            let countMatches = matchRegex(stringToCheck: matchedSubstring, regex: Constants.multiplierRegex)
            for countMatch in countMatches {
                if let substringRange = Range(countMatch.range, in: matchedSubstring) {
                    let countString = String(matchedSubstring[substringRange])
                    multipliers.append(Int(countString) ?? 1)
                }
            }
            if multipliers.count > 0 {
                let numberOfStitches = match.multiplier * multipliers.reduce(1, *)
                let result = Result(pattern: matchedSubstring, count: numberOfStitches)
                results.append(result)
            } else {
                let numberOfStitches = match.multiplier
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
        
        let matches = inputRegex.matches(
            in: stringToCheck,
            options: [],
            range: inputRange
        )
        
        return matches
    }
    
    func extractMatchText(group: NSTextCheckingResult, name: String, in fullString: String) -> String {
        let matchRange = group.range(withName: name)
        
        // Extract the substring matching the named capture group
        if let substringRange = Range(matchRange, in: fullString) {
            let matchedSubstring = String(fullString[substringRange])
            return matchedSubstring
        }
        return ""
    }
}

extension String {
    func toInt() -> Int {
        switch self {
        case "one":
            return 1
        case "two":
            return 2
        default:
            return 0
        }
    }
}
