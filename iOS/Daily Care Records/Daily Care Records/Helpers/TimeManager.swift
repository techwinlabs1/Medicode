//
//  TimeManager.swift
//  Habesha
//
//  Created by Techwin Labs on 2/21/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import Foundation

class TimeManager {
    
    class func localDatetoUTC(strDate:String) -> String {
        //  UTC
        let dateformattor = DateFormatter()
        dateformattor.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformattor.timeZone = NSTimeZone.local
        let dt1 = dateformattor.date(from: strDate)
        dateformattor.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformattor.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        let convertedDate = dateformattor.string(from: dt1!)
        return convertedDate
    }
    
    class func utcDatetoLocal(strDate:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: strDate)// create   date from string
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date!)
    }
    class func onlyUTCDatetoLocal(strDate:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: strDate)// create   date from string
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date!)
    }
    
    
    
    class func elapsedTimeSinceNow(fromDate:Date) -> NSMutableString {
        
        let timeLeft = NSMutableString.init()
        let dateNow = Date()
        var seconds : NSInteger = NSInteger(dateNow.timeIntervalSince(fromDate))
        let days : Int = Int(floor(Double(seconds / (3600*24))))
        if days > 0 { seconds -= days * 3600 * 24 }
        let hours : Int = Int(floor(Double(seconds / 3600)))
        if hours > 0 { seconds -= hours * 3600 }
        let minutes : Int = Int(floor(Double(seconds / 60)))
        
        if days > 0 {
            if days == 1 {
                timeLeft.append("\(days) Day")
            } else {
                timeLeft.append("\(days) Days")
            }
            return timeLeft
        }
        if hours > 0 {
            timeLeft.append("\(hours) hr")
            return timeLeft
        }
        if minutes > 0 {
            timeLeft.append("\(minutes) min")
            return timeLeft
        }
        return timeLeft
    }
    
    class func remainingSeconds(startDate:String,endDate:String) -> NSInteger {
        let start = dateFromString(strDate: startDate, fromFormat: "yyyy-MM-dd HH:mm:ss")
        let end = dateFromString(strDate: endDate, fromFormat: "yyyy-MM-dd HH:mm:ss")
        let seconds : NSInteger = NSInteger(end.timeIntervalSince(start))
        return seconds
    }

    class func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }

    class func FormatDateString(strDate : String, fromFormat : String, toFormat : String) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = fromFormat
        
        let formattedDate = dateFormatter.date(from: strDate)
        
        dateFormatter.dateFormat = toFormat
        let convertedDate = dateFormatter.string(from: formattedDate!)
        
        return convertedDate
    }
    
    class func currentDate() -> String {
        return FormatDateString(strDate: String(describing: Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "YYYY-mm-dd")
    }
    
    // date Format for NSDate : yyyy-MM-dd HH:mm:ss +zzzz
    // date Format to send php : yyyy-MM-dd
    
    class func dateFromString(strDate : String, fromFormat : String) -> Date {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = fromFormat
        
        let formattedDate = dateFormatter.date(from: strDate)
        
        return formattedDate!
    }
    
}
