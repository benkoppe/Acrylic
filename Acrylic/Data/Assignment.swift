//
//  Assignment.swift
//  Acrylic
//
//  Created by Ben K on 9/28/21.
//

import SwiftUI
import WidgetKit

class AssignmentArray: ObservableObject {
    var key: String
    
    @Published var assignments: [Assignment] {
        didSet {
            save()
        }
    }
    
    init(key: String) {
        print("fetching")
        let defaults = UserDefaults.init(suiteName: "group.com.benk.acrylic")
        let coursesData: [Data] = defaults?.array(forKey: key) as? [Data] ?? []
        print(coursesData.description)
        
        var arr: [Assignment] = []
        for data in coursesData {
            if let assignment = Assignment.getAssignment(from: data) {
                arr.append(assignment)
            }
        }
        
        self.key = key
        self.assignments = arr
    }
    
    func save() {
        let defaults = UserDefaults.init(suiteName: "group.com.benk.acrylic")
        defaults?.setValue(Assignment.getData(array: assignments), forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct Assignment: Comparable, Equatable, Hashable, Identifiable {
    var id: UUID = UUID()
    
    let name: String
    let due: Date
    let courseID: Int
    let courseName: String
    let courseOrder: Int
    let url: URL
    let color: Color
    
    static func < (lhs: Assignment, rhs: Assignment) -> Bool {
        if lhs.due.roundMinuteDown() != rhs.due.roundMinuteDown() {
            return lhs.due < rhs.due
        } else {
            return lhs.courseOrder < rhs.courseOrder
        }
    }
    
    static func sampleAssignment() -> Assignment {
        return Assignment(name: "NOT FOUND", due: Date(), courseID: 0, courseName: "NOT FOUND", courseOrder: 0, url: URL(string: "https://www.google.com")!, color: Color(.black))
    }
    static func sampleAssignment(name: String, daysAhead: Int, courseName: String, courseOrder: Int, courseColor: Color) -> Assignment {
        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        var due = Date()
        for _ in 1 ... daysAhead {
        due = Calendar.current.nextDate(after: due, matching: components, matchingPolicy: .nextTime, direction: .forward)!
        }
        return Assignment(name: name, due: due, courseID: 0, courseName: courseName, courseOrder: courseOrder, url: URL(string: "https://www.google.com")!, color: courseColor)
    }
    
    static func sampleAssignments() -> [Assignment] {
        var assignments: [Assignment] = []
        assignments.append(sampleAssignment(name: "Water Lab", daysAhead: 1, courseName: "Biology", courseOrder: 0, courseColor: Color("green")))
        assignments.append(sampleAssignment(name: "Chapter 3 Notes and Presentation", daysAhead: 1, courseName: "AP Calculus", courseOrder: 1, courseColor: Color("red")))
        assignments.append(sampleAssignment(name: "Poetry Notes", daysAhead: 2, courseName: "Literature", courseOrder: 3, courseColor: Color("blue")))
        assignments.append(sampleAssignment(name: "Chapter Seventeen Identities/Quiz", daysAhead: 3, courseName: "APUSH", courseOrder: 4, courseColor: Color("yellow")))
        assignments.append(sampleAssignment(name: "Chapter 4 Notes", daysAhead: 4, courseName: "AP Calculus", courseOrder: 1, courseColor: Color("red")))
        
        return assignments
    }
    
    enum CodingKeys: CodingKey {
        case id, name, due, courseID, courseName, courseOrder, url, color
    }
}

extension Assignment {
    func getData() -> Data {
        do {
            let encoder = JSONEncoder()
            return try encoder.encode(self)
        } catch {
            print("Could not encode \(self)")
            return Data()
        }
    }
    
    static func getAssignment(from data: Data) -> Assignment? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Assignment.self, from: data)
        } catch {
            print("Could not decode \(data)")
            return nil
        }
    }
    
    static func getData(array: [Assignment]) -> [Data] {
        var arr: [Data] = []
        for course in array {
            arr.append(course.getData())
        }
        return arr
    }
}

extension Assignment: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        
        try container.encode(name, forKey: .name)
        try container.encode(due, forKey: .due)
        try container.encode(url, forKey: .url)
        
        try container.encode(courseID, forKey: .courseID)
        try container.encode(courseName, forKey: .courseName)
        try container.encode(courseOrder, forKey: .courseOrder)
        
        let uiColor = UIColor(color)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .color)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        
        name = try container.decode(String.self, forKey: .name)
        due = try container.decode(Date.self, forKey: .due)
        url = try container.decode(URL.self, forKey: .url)
        
        courseID = try container.decode(Int.self, forKey: .courseID)
        courseName = try container.decode(String.self, forKey: .courseName)
        courseOrder = try container.decode(Int.self, forKey: .courseOrder)
        
        let colorData = try container.decode(Data.self, forKey: .color)
        let uiColor = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor
        color = Color(uiColor ?? UIColor.white)
    }
}
