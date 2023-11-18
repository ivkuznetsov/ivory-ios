//
//  Double+Additions.swift
//  TheDoLectures
//
//  Created by Ilya Kuznetsov on 6/23/18.
//  Copyright © 2018 Ilya Kuznetsov. All rights reserved.
//

import Foundation

extension Double {
    
    func toTimeString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: self)!
    }
}
