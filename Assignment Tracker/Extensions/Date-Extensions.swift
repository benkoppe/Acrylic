//
//  Date-Extensions.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/2/21.
//

import Foundation

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func getYearDay() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "DD"
        return Int(formatter.string(from: self)) ?? -1
    }
}
