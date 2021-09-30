//
//  Course.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/4/21.
//

import SwiftUI
import WidgetKit

class CourseArray: ObservableObject {
    var key: String
    
    @Published var courses: [Course] {
        didSet {
            save()
        }
    }
    
    init(key: String = "courses") {
        let defaults = UserDefaults.init(suiteName: "group.com.benk.acrylic")
        let coursesData: [Data] = defaults?.array(forKey: key) as? [Data] ?? []
        
        var arr: [Course] = []
        for data in coursesData {
            if let course = Course.getCourse(from: data) {
                arr.append(course)
            }
        }
        
        self.key = key
        self.courses = arr
    }
    
    func save() {
        let defaults = UserDefaults.init(suiteName: "group.com.benk.acrylic")
        defaults?.setValue(Course.getData(array: courses), forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

class Course: Codable, ObservableObject, Identifiable, Equatable {
    @Published var code: Int
    @Published var name: String
    @Published var teacher: String?
    @Published var order: Int
    
    @Published var colorR: Double
    @Published var colorG: Double
    @Published var colorB: Double
    @Published var colorA: Double
    
    let id: UUID
    
    var color: Color {
        get {
            Color(red: colorR, green: colorG, blue: colorB, opacity: colorA)
        }
        set {
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
        
        self.id = UUID()
    }
    
    enum CodingKeys: CodingKey {
        case code, name, teacher, order, colorR, colorG, colorB, colorA, id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(code, forKey: .code)
        try container.encode(name, forKey: .name)
        try container.encode(teacher, forKey: .teacher)
        try container.encode(order, forKey: .order)
        
        try container.encode(colorR, forKey: .colorR)
        try container.encode(colorG, forKey: .colorG)
        try container.encode(colorB, forKey: .colorB)
        try container.encode(colorA, forKey: .colorA)
        
        try container.encode(id, forKey: .id)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        code = try container.decode(Int.self, forKey: .code)
        name = try container.decode(String.self, forKey: .name)
        teacher = try container.decode(String?.self, forKey: .teacher)
        order = try container.decode(Int.self, forKey: .order)
        
        colorR = try container.decode(Double.self, forKey: .colorR)
        colorG = try container.decode(Double.self, forKey: .colorG)
        colorB = try container.decode(Double.self, forKey: .colorB)
        colorA = try container.decode(Double.self, forKey: .colorA)
        
        id = try container.decode(UUID.self, forKey: .id)
    }
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.code == rhs.code
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
    
    static func getCourse(from data: Data) -> Course? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Course.self, from: data)
        } catch {
            print("Could not decode \(data)")
            return nil
        }
    }
    
    static func getData(array: [Course]) -> [Data] {
        var arr: [Data] = []
        for course in array {
            arr.append(course.getData())
        }
        return arr
    }
}
