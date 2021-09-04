//
//  Course.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/4/21.
//

import SwiftUI

struct Course2: Codable {
    let code: Int
    let name: String
    let teacher: String?
    let order: Int
    
    var colorR: Double
    var colorG: Double
    var colorB: Double
    var colorA: Double
    
    public var color: Color {
        get {
            return Color(red: colorR, green: colorG, blue: colorB, opacity: colorA)
        } set {
            let rgba = UIColor(newValue).rgba
            self.colorR = rgba.red
            self.colorG = rgba.green
            self.colorB = rgba.blue
            self.colorA = rgba.alpha
        }
    }
    
    init(name: String, code: Int, order: Int, color: Color, teacher: String? = nil) {
        self.name = name
        self.code = code
        self.order = order
        self.teacher = teacher
        
        let rgba = UIColor(color).rgba
        self.colorR = rgba.red
        self.colorG = rgba.green
        self.colorB = rgba.blue
        self.colorA = rgba.alpha
    }
    
    func getData() -> Data {
        do {
            let encoder = JSONEncoder()
            return try encoder.encode(self)
        } catch {
            print("Could not encode \(self)")
            return Data()
        }
    }
    
    static func getCourse(from data: Data) -> Course2? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Course2.self, from: data)
        } catch {
            print("Could not decode \(data)")
            return nil
        }
    }
    
    static func getData(array: [Course2]) -> [Data] {
        var arr: [Data] = []
        for course in array {
            arr.append(course.getData())
        }
        return arr
    }
}
