//
//  Assignment.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/30/21.
//

import SwiftUI

typealias TodoList = [TodoItem]

struct TodoItem: Codable {
    let contextType: String
    let assignment: TodoAssignment?
    
    enum CodingKeys: String, CodingKey {
        case contextType = "context_type"
        case assignment
    }
}

struct TodoAssignment: Codable {
    let name: String
    let dueAt: String
    let courseID: Int
    let htmlURL: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case dueAt = "due_at"
        case courseID = "course_id"
        case htmlURL = "html_url"
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
        if lhs.due != rhs.due {
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
        let due = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime, direction: .forward)!
        return Assignment(name: name, due: due, courseID: 0, courseName: courseName, courseOrder: courseOrder, url: URL(string: "https://www.google.com")!, color: courseColor)
    }
    
    static func sampleAssignments() -> [Assignment] {
        var assignments: [Assignment] = []
        assignments.append(sampleAssignment())
        assignments.append(sampleAssignment())
        assignments.append(sampleAssignment())
        assignments.append(sampleAssignment())
        assignments.append(sampleAssignment())
        
        return assignments
    }
}

struct CanvasCourse: Codable, Hashable {
    let id: Int
    let name: String?
    let isFavorite: Bool?
    let term: Term?
    let teachers: [Teacher]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, term, teachers
        case isFavorite = "is_favorite"
    }
}

struct Term: Codable, Hashable {
    let startDate: String?
    let endDate: String?
    
    enum CodingKeys: String, CodingKey {
        case startDate = "start_at"
        case endDate = "end_at"
    }
}

struct Teacher: Codable, Hashable {
    let name: String
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case name = "display_name"
        case avatarURL = "avatar_image_url"
    }
}

struct CanvasUser: Codable, Hashable {
    let name: String
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case avatarURL = "avatar_url"
    }
}
