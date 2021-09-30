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
