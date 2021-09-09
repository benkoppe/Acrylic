//
//  WidgetView.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/30/21.
//

import SwiftUI

struct AssignmentList: View {
    @State private var doneFetching = false
    
    @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var auth: String = ""
    @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var prefixes: [String] = []
    @State private var assignments: [Assignment] = []
    @State private var fetchState: FetchState = .loading
    @State private var errorType: ErrorType = .none
    
    @EnvironmentObject var courseArray: CourseArray
    
    enum FetchState {
        case success, loading, failure
    }
    enum ErrorType {
        case none, badLoad, badURL, badAuth
    }
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM dd"
        return formatter
    }
    
    var body: some View {
        NavigationView {
            switch fetchState {
            
            case .success:
                successView(assignments: $assignments)
                
            default:
                ProgressView("Loading Assignments...")
                    .offset(x: 0, y: -40)
                
            }
        }
        .onAppear(perform: fetchAssignments)
    }
    
    struct successView: View {
        @Binding var assignments: [Assignment]
        @State private var placedFirstHeader = false
        
        var splitAssignments: [[Assignment]] {
            if assignments.count > 0 {
                var assy: [[Assignment]] = []
                var shortAssy: [Assignment] = [assignments[0]]
                var lastDate = assignments[0].due
                
                for assignment in assignments {
                    if assignment.due.getYearDay() != lastDate.getYearDay() {
                        assy.append(shortAssy)
                        shortAssy = []
                        shortAssy.append(assignment)
                    }
                    shortAssy.append(assignment)
                    lastDate = assignment.due
                }
                assy.append(shortAssy)
                
                return assy
                
            } else { return [] }
        }
        
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ZStack {
                        Color("WidgetBackground")
                            .clipShape(
                                RoundedRectangle(cornerRadius: 25)
                            )
                            .padding(.vertical, 1)
                            .padding(3)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(0 ..< assignments.count) { index in
                                if index < assignments.count {
                                    assignmentItem(assignments: assignments, index: index)
                                }
                            }
                            
                            ForEach(splitAssignments, id: \.self) { assignmentArray in
                                Text("\(assignmentArray[0].due)")
                                    .font(.title)
                                ForEach(assignmentArray, id: \.self) { assignment in
                                    Text(assignment.name)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .padding(.vertical, 5)
                        .padding(.leading, 4)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Assignments")
            //.navigationBarTitleDisplayMode(.inline)
        }
        
        struct assignmentItem: View {
            init(assignments: [Assignment], index: Int) {
                self.assignment = assignments[index]
                self.includeHeader = index == 0 || assignments[index].due.getYearDay() != assignments[index-1].due.getYearDay()
                self.spaceTop = index != 0
            }
            
            let assignment: Assignment
            let includeHeader: Bool
            let spaceTop: Bool
            
            var timeFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                return formatter
            }
            
            var body: some View {
                
                if spaceTop && includeHeader {
                    Divider()
                        .padding(.top, 12)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 2)
                }
                
                if includeHeader {
                    Text(createTitleText(for: assignment.due))
                        //.font(.system(.title, design: .rounded))
                        .font(.system(size: 25, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                        .brightness(0.5)
                        .padding(.bottom, 7)
                }
                
                Link(destination: assignment.url) {
                    HStack {
                        Text(String("\u{007C}"))
                            .font(.system(size: 42, weight: .semibold, design: .rounded))
                            .foregroundColor(assignment.color)
                            .offset(x: 7, y: -3.5)
                            .padding(.leading, 5)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(assignment.name)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                                .padding(.bottom, 1)
                            
                            HStack(spacing: 0) {
                                Text(timeFormatter.string(from: assignment.due))
                                    .contrast(0.5)
                                
                                Text(" • ")
                                
                                Text(assignment.courseName)
                                    .foregroundColor(assignment.color)
                            }
                            .font(.system(size: 8, weight: .semibold, design: .default))
                            .lineLimit(1)
                            .offset(x: 2, y: 0)
                        }
                    }
                    .foregroundColor(.primary)
                    .offset(x: 10, y: 0)
                    
                }
                
            }
            
            func createTitleText(for date: Date) -> String {
                let day = date.getYearDay()
                var formatter: DateFormatter {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEEE, MMM d"
                    return formatter
                }
                
                if day == Date().getYearDay() {
                    return "Today"
                } else if day == (Calendar.current.date(byAdding: .day, value: 1, to: Date())!).getYearDay() {
                    return "Tomorrow"
                } else {
                    return formatter.string(from: date)
                }
            }
        }
    }
    
    func fetchAssignments() {
        fetchState = .loading
        assignments = []
        var loadedPrefixes: [String] = []
        errorType = .none
        
        for prefix in prefixes {
            fetchState = .loading
            
            let urlString = "https://\(prefix).instructure.com/api/v1/users/self/todo?per_page=100"
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                fetchState = .failure
                errorType = .badURL
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
                        fetchState = .failure
                        errorType = .badAuth
                        return
                    }
                }
                
                if let data = data {
                    let decoder = JSONDecoder()
                    if let list = try? decoder.decode(TodoList.self, from: data) {
                        for item in list {
                            if let assignment = item.assignment, let courseAssignment = createAssignment(assignment) {
                                self.assignments.append(courseAssignment)
                            }
                        }
                        
                        if isLastPrefix {
                            assignments.sort()
                            fetchState = .success
                        }
                    }
                } else {
                    fetchState = .failure
                    errorType = .badLoad
                    return
                }
            }.resume()
        }
    }
    
    func createAssignment(_ todoAssignment: TodoAssignment) -> Assignment? {
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
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentList(auth: "26~yxSOVTuYIh0Fx9dMdm1VgaMXyv7VvCa1Ub7JHMZUhzJpakh254MmtBblpzmv7Gb9", prefixes: ["hsccsd"])
            .preferredColorScheme(.dark)
    }
}
