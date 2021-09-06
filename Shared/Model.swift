//
//  Model.swift
//  StitchCounter
//
//  Created by Zheng on 9/6/21.
//

import Foundation

struct Constants {
    static var multiplierRegex = #"([0-9]+)\b|\b([0-9]+)"#
    static var groupRegex = #"\*(?<contents>[^*]+)\* +(?<groupMultiplier>x?[0-9]+)( times)?"#
}

struct Result: Identifiable {
    let id = UUID()
    var pattern = "st"
    var count = 0
    var groupMultiplier: Int?
}

struct Stitch: Identifiable, Equatable {
    let id = UUID()
    var name = ""
    var count = 1
}
class GroupOfStitchesWithSameCount {
    var stitches = [Stitch]()
    var count = 1
}
