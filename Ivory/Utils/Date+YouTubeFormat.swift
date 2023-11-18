//
//  Date+YouTubeFormat.swift
//  YouPlayer
//
//  Created by Ilya Kuznetsov on 11/24/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

import Foundation

extension Date {
    
    static func dateWith(youtubeString: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        return dateFormatter.date(from: youtubeString)
    }
}
