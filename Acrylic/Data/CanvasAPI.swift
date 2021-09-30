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

private func asyncFetch<T: Codable>(request: URLRequest) async throws -> T {
    let (data, response) = try await URLSession.shared.data(for: request)
    
    if let response = response as? HTTPURLResponse {
        if response.statusCode == 401 {
            throw FetchError.noAuth
        }
        if response.statusCode == 404 {
            throw FetchError.badPrefix
        }
    }
    
    guard let fetch = try? JSONDecoder().decode(T.self, from: data)  else {
        throw FetchError.badLoad
    }
    
    return fetch
}

private func asyncFetchGroup<T: Codable & RangeReplaceableCollection>(auth: String, prefixes: [String], fetch: @escaping (String, String) async throws -> T) async throws -> T {
    return try await withThrowingTaskGroup(of: T.self) { group in
        var fetchGroup: T = [] as! T
        
        if prefixes.isEmpty {
            throw FetchError.noPrefixes
        }
        
        for prefix in prefixes {
            group.addTask {
                return try await fetch(auth, prefix)
            }
            
            for try await arr in group {
                fetchGroup += arr
            }
        }
        
        return fetchGroup
    }
}

func asyncFetchAssignments(auth: String, prefixes: [String]) async throws -> [TodoAssignment] {
    return try await asyncFetchGroup(auth: auth, prefixes: prefixes, fetch: asyncFetchAssignments)
}

private func asyncFetchAssignments(auth: String, prefix: String) async throws -> [TodoAssignment] {
    guard let url = URL(string: "https://\(prefix).instructure.com/api/v1/users/self/todo?per_page=100") else {
        throw FetchError.badURL
    }
    
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = ["Authorization" : "Bearer " + auth]
    
    let todoList: TodoList = try await asyncFetch(request: request)
    
    var fetch: [TodoAssignment] = []
    
    for item in todoList {
        if let assignment = item.assignment {
            fetch.append(assignment)
        }
    }
    
    return fetch
}

func asyncFetchCourses(auth: String, prefixes: [String]) async throws -> [CanvasCourse] {
    return try await asyncFetchGroup(auth: auth, prefixes: prefixes, fetch: asyncFetchCourses)
}

private func asyncFetchCourses(auth: String, prefix: String) async throws -> [CanvasCourse] {
    guard let url = URL(string: "https://\(prefix).instructure.com/api/v1/courses?per_page=100&include[]=term&include[]=favorites&include[]=teachers") else {
        throw FetchError.badURL
    }
    
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = ["Authorization" : "Bearer " + auth]
    
    return try await asyncFetch(request: request)
}

func asyncLoadUser(auth: String, prefixes: [String]) async throws -> [CanvasUser] {
    return try await asyncFetchGroup(auth: auth, prefixes: prefixes, fetch: asyncLoadUser)
}

private func asyncLoadUser(auth: String, prefix: String) async throws -> [CanvasUser] {
    guard let url = URL(string: "https://\(prefix).instructure.com/api/v1/users/self/profile") else {
        throw FetchError.badURL
    }
    
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = ["Authorization" : "Bearer " + auth]
    
    return [try await asyncFetch(request: request)]
}

func asyncFetchImage(urlString: String) async throws -> UIImage {
    guard let url = URL(string: urlString) else {
        throw FetchError.badURL
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    
    if let image = UIImage(data: data) {
        return image
    }
    
    throw FetchError.badLoad
}

func asyncFetchUserImage(userArray: [CanvasUser]) async -> Data? {
    for user in userArray {
        if let avatarURL = user.avatarURL {
            let pfp = try? await asyncFetchImage(urlString: avatarURL)
            if let pngData = pfp?.pngData() {
                return pngData
            }
        }
    }
    return nil
}
