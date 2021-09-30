//
//  CanvasAPI.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/13/21.
//

import Foundation
import SwiftUI

enum FetchError: Error {
    case badURL, noAuth, badLoad, noPrefixes, badPrefix
}

func asyncFetchAssignments(auth: String, prefixes: [String]) async throws -> [TodoAssignment] {
    var fetchedAssignments: [TodoAssignment] = []

    if prefixes.isEmpty {
        throw FetchError.noPrefixes
    }

    for prefix in prefixes {
        guard let url = URL(string: "https://\(prefix).instructure.com/api/v1/users/self/todo?per_page=100") else {
            throw FetchError.badURL
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization" : "Bearer " + auth]

        let (data, response) = try await URLSession.shared.data(for: request)

        if let response = response as? HTTPURLResponse {
            if response.statusCode == 401 {
                throw FetchError.noAuth
            }
            if response.statusCode == 404 {
                throw FetchError.badPrefix
            }
        }

        if let list = try? JSONDecoder().decode(TodoList.self, from: data) {
            for item in list {
                if let assignment = item.assignment {
                    fetchedAssignments.append(assignment)
                }
            }

        }
    }

    return fetchedAssignments
}

func createAssignment(courseArray: CourseArray, _ todoAssignment: TodoAssignment) -> Assignment? {
    var id: Int?
    var name: String?
    var order: Int?
    var color: Color?
    for course in courseArray.courses {
        if course.code == todoAssignment.courseID {
            id = course.code
            name = course.name
            order = course.order
            color = course.color
            break
        }
    }
    guard let courseID = id, let courseName = name, let courseOrder = order, let courseColor = color else { return nil }
    guard let url = URL(string: todoAssignment.htmlURL) else { return nil }
    guard let due = ISO8601DateFormatter().date(from: todoAssignment.dueAt) else { return nil }
    
    return Assignment(name: todoAssignment.name, due: due, courseID: courseID, courseName: courseName, courseOrder: courseOrder, url: url, color: courseColor)
}

func asyncFetchCourses(auth: String, prefixes: [String]) async throws -> [CanvasCourse] {
    var fetchedCourses: [CanvasCourse] = []
    
    if prefixes.isEmpty {
        throw FetchError.noPrefixes
    }
    
    for prefix in prefixes {
        guard let url = URL(string: "https://\(prefix).instructure.com/api/v1/courses?per_page=100&include[]=term&include[]=favorites&include[]=teachers") else {
            throw FetchError.badURL
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization" : "Bearer " + auth]
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse {
            if response.statusCode == 401 {
                throw FetchError.noAuth
            }
            if response.statusCode == 404 {
                throw FetchError.badPrefix
            }
        }
        
        if let list = try? JSONDecoder().decode([CanvasCourse].self, from: data) {
            for course in list {
                fetchedCourses.append(course)
            }
        }
    }
    
    return fetchedCourses
}

func asyncLoadUser(auth: String, prefixes: [String]) async throws -> [CanvasUser] {
    var fetchedUsers: [CanvasUser] = []
    
    if prefixes.isEmpty {
        throw FetchError.noPrefixes
    }
    
    for prefix in prefixes {
        guard let url = URL(string: "https://\(prefix).instructure.com/api/v1/users/self/profile") else {
            throw FetchError.badURL
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization" : "Bearer " + auth]
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse {
            if response.statusCode == 401 {
                throw FetchError.noAuth
            }
            if response.statusCode == 404 {
                throw FetchError.badPrefix
            }
        }
        
        if let user = try? JSONDecoder().decode(CanvasUser.self, from: data) {
            fetchedUsers.append(user)
        }
    }
    
    return fetchedUsers
}
