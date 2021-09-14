//
//  CanvasAPI.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/13/21.
//

import Foundation
import SwiftUI

func fetchAssignments(auth: String, prefixes: [String], completion: @escaping (Result<[TodoAssignment], FetchError>) -> Void) {
    var loadedPrefixes: [String] = []
    var fetchedAssignments: [TodoAssignment] = []
    
    for prefix in prefixes {
        let urlString = "https://\(prefix).instructure.com/api/v1/users/self/todo?per_page=100"
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            completion(.failure(.badURL))
            return
        }
        var request = URLRequest(url: url)
        let auth = auth
        request.allHTTPHeaderFields = ["Authorization" : "Bearer " + auth]
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            loadedPrefixes.append(prefix)
            var isLastPrefix: Bool {
                for prefix in prefixes {
                    if !loadedPrefixes.contains(prefix) {
                        return false
                    }
                }
                return true
            }
            
            if let response = response, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    completion(.failure(.noAuth))
                    return
                }
                if httpResponse.statusCode == 404 {
                    completion(.failure(.badPrefix))
                    return
                }
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                if let list = try? decoder.decode(TodoList.self, from: data) {
                    for item in list {
                        if let assignment = item.assignment {
                            fetchedAssignments.append(assignment)
                        }
                    }
                    
                    if isLastPrefix {
                        completion(.success(fetchedAssignments))
                        return
                    }
                }
            } else {
                completion(.failure(.badLoad))
                return
            }
        }.resume()
    }
    if prefixes.isEmpty {
        completion(.failure(.noPrefixes))
        return
    }
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
