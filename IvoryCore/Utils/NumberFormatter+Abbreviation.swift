//
//  NumberFormatter+Abbreviation.swift
//  YouPlayer
//
//  Created by Ilya Kuznetsov on 11/29/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

import Foundation

extension NumberFormatter {
    
    private static let abbrFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.allowsFloats = true
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    private static let abbreviations: [[String:Any]] = [ ["threshold":0, "divisor":1, "suffix":""],
                                                          ["threshold":1000, "divisor":1000, "suffix":"K"],
                                                          ["threshold":1000000, "divisor":1000000, "suffix":"M"] ]
    
    static func abbreviatedStringFrom(number: Int64) -> String {
        
        let startValue = abs(number)
        
        var abbreviation: [String:Any] = abbreviations.first!
        for abbr in abbreviations {
            if startValue < Int64(abbr["threshold"] as! Int) {
                break
            }
            abbreviation = abbr
        }
        
        let value = number / Int64(abbreviation["divisor"] as! Int)
        abbrFormatter.locale = Locale.current
        abbrFormatter.positiveSuffix = abbreviation["suffix"] as? String
        abbrFormatter.negativeSuffix = abbreviation["suffix"] as? String
        return abbrFormatter.string(for: value) ?? "0"
    }
}
