//
//  Storage.swift
//  StitchCounter
//
//  Created by Zheng on 9/6/21.
//

import Foundation

struct Storage {
    static func buildStitchesString(stitches: [Stitch]) -> String {
        var string = ""
        for (index, stitch) in stitches.enumerated() {
            if index != stitches.count - 1 {
                string += "\(stitch.name)=\(stitch.count)" + ","
            } else {
                string += "\(stitch.name)=\(stitch.count)"
            }
        }
        return string
    }
    static func readStitchesString(string: String) -> [Stitch] {
        var stitches = [Stitch]()
        
        let stitchesStringSeparated = string.components(separatedBy: ",")
        for stitchString in stitchesStringSeparated {
            let stitchStringSeparated = stitchString.components(separatedBy: "=")
            let name = String(stitchStringSeparated[0])
            let count = Int(stitchStringSeparated[1]) ?? 1
            let stitch = Stitch(name: name, count: count)
            stitches.append(stitch)
        }
        
        return stitches
    }
}
struct RegexBuilder {
    static func buildRegex(stitches: [Stitch]) -> String {
        var groupedStitches = [GroupOfStitchesWithSameCount]()
        
        for stitch in stitches {
            if let stitchGroup = groupedStitches.first(where: { $0.count == stitch.count }) {
                stitchGroup.stitches.append(stitch)
            } else {
                let stitchGroup = GroupOfStitchesWithSameCount()
                stitchGroup.stitches = [stitch]
                stitchGroup.count = stitch.count
                groupedStitches.append(stitchGroup)
            }
        }
        
        var regexes = [String]()
        for group in groupedStitches {
            print(group.count, group.stitches)
            
            var stitchedString = ""
            for (index, stitch) in group.stitches.enumerated() {
                if index != group.stitches.count - 1 {
                    stitchedString += stitch.name + "|"
                } else {
                    stitchedString += stitch.name
                }
            }
            let regex = "(?<count\(group.count)>([0-9])*(\(stitchedString))( {1}[0-9]+)?)"
            regexes.append(regex)
        }
        
        var finalRegex = ""
        for (index, regex) in regexes.enumerated() {
            if index != regexes.count - 1 {
                finalRegex += regex + "|"
            } else {
                finalRegex += regex
            }
        }
        print(finalRegex)
        return finalRegex
    }
}
