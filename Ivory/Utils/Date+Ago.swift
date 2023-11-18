//
//  Date+Ago.swift
//  YouPlayer
//
//  Created by Ilya Kuznetsov on 11/29/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

import Foundation

extension Date {
    
    static let second = 1.0
    static let minute = { second * 60.0 }()
    static let hour = { minute * 60.0 }()
    static let day = { hour * 24.0 }()
    static let month = { day * 30.0 }()
    
    var dateAgo: String {
        Date.timeInterval(startDate: self, endDate: Date())
    }
    
    static func timeInterval(startDate: Date, endDate: Date) -> String {
        
        let delta = endDate.timeIntervalSince(startDate)
        
        if delta < 1 * minute {
            return delta == 1 ? "one second ago" : "\(Int(delta)) seconds ago"
        }
        if delta < 2 * minute {
            return "a minute ago"
        }
        if delta < 45 * minute {
            return "\(Int(floor(delta / minute))) minutes ago"
        }
        if delta < 90 * minute {
            return "a hour ago"
        }
        if delta < 24 * hour {
            return "\(Int(floor(delta / hour))) hours ago"
        }
        if delta < 48 * hour {
            return "yesterday"
        }
        if delta < 30 * day {
            return "\(Int(floor(delta / day))) days ago"
        }
        if delta < 12 * month {
            let months = Int(floor(delta / month))
            return months <= 1 ? "one month ago" : "\(months) months ago"
        } else {
            let years = Int(floor(delta / month / 12))
            return years <= 1 ? "one year ago" : "\(years) years ago"
        }
    }
}
