//
//  Assignment_Widget.swift
//  Assignment Widget
//
//  Created by Ben K on 9/3/21.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    
    @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var auth: String = ""
    @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var prefixes: [String] = []
    let courses: [Course] = []
    
    enum FetchError: Error {
        case badURL, noAuth, badLoad
    }
    
    func placeholder(in context: Context) -> Entry {
        print("placeholder")
        return Entry(date: Date(), assignments: Assignment.sampleAssignments())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        print("\(auth)")
        print("\(prefixes)")
        print("\(courses[0].uName)")
        if !context.isPreview {
            fetchAssignments() { result in
                print("built successfully")
                switch result {
                case .success(let assignments):
                    print(assignments)
                    let entry = Entry(date: Date(), assignments: assignments)
                    completion(entry)
                case .failure(let error):
                    print(error.localizedDescription)
                    let entry = Entry(date: Date(), assignments: Assignment.sampleAssignments())
                    completion(entry)
                }
            }
        } else {
            print("did not build")
            let assignments = Assignment.sampleAssignments()
            let entry = Entry(date: Date(), assignments: assignments)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        print("hello?")
        print("\(auth)")
        print("\(prefixes)")
        print("\(courses[0].uName)")
        let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 1, to: Date())!
        
        if !context.isPreview {
            print("beginning fetch")
            fetchAssignments() { result in
                switch result {
                case .success(let assignments):
                    let entry = Entry(date: Date(), assignments: assignments)
                    let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                    completion(timeline)
                case .failure(let error):
                    print(error.localizedDescription)
                    let entry = Entry(date: Date(), assignments: Assignment.sampleAssignments())
                    let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                    completion(timeline)
                }
            }
        } else {
            print("did not build")
            let assignments = Assignment.sampleAssignments()
            let entry = Entry(date: Date(), assignments: assignments)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
        
    }
    
    func fetchAssignments(completion: @escaping (Result<[Assignment], FetchError>) -> Void) {
        var assignments: [Assignment] = []
        var loadedPrefixes: [String] = []
        
        for prefix in prefixes {
            let urlString = "https://\(prefix).instructure.com/api/v1/users/self/todo"
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                completion(.failure(.badURL))
                return
            }
            var request = URLRequest(url: url)
            let auth = auth
            request.allHTTPHeaderFields = ["Authorization" : "Bearer " + auth]
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                print("started session")
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
                    }
                }
                
                if let data = data {
                    let decoder = JSONDecoder()
                    if let list = try? decoder.decode(TodoList.self, from: data) {
                        for item in list {
                            if let assignment = item.assignment, let courseAssignment = createAssignment(assignment) {
                                assignments.append(courseAssignment)
                            }
                        }
                        
                        if isLastPrefix {
                            assignments.sort()
                            completion(.success(assignments))
                        }
                    }
                } else {
                    completion(.failure(.badLoad))
                }
            }.resume()
        }
    }
    
    func createAssignment(_ todoAssignment: TodoAssignment) -> Assignment? {
        var id: Int?
        var name: String?
        var order: Int?
        var color: Color?
        for course in courses {
            if course.uCode == todoAssignment.courseID {
                id = course.uCode
                name = course.uName
                order = course.uOrder
                color = course.uColor
                break
            }
        }
        guard let courseID = id, let courseName = name, let courseOrder = order, let courseColor = color else { return nil }
        guard let url = URL(string: todoAssignment.htmlURL) else { return nil }
        guard let due = ISO8601DateFormatter().date(from: todoAssignment.dueAt) else { return nil }
        
        return Assignment(name: todoAssignment.name, due: due, courseID: courseID, courseName: courseName, courseOrder: courseOrder, url: url, color: courseColor)
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let assignments: [Assignment]
}


/*struct Assignment_WidgetEntryView : View {
    var entry: Entry

    var body: some View {
        Text(entry.assignments[0].due, style: .time)
    }
}*/

//
//  AssignmentWidgetView.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/3/21.
//

struct Assignment_WidgetEntryView: View {
    var entry: Entry
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM dd"
        return formatter
    }
    
    var body: some View {
        //switch fetchState {
        
        //case .success:
        /*if entry.assignments.count > 0 {
            successView(assignments: entry.assignments)
        } else {
            Text("Hello")
        }*/
        if entry.assignments.count > 0 {
            Text("\(entry.assignments[0].name)")
        } else {
            Text("Hello")
        }
            
        /*default:
            ProgressView()
            
        }*/
    }
    
    struct successView: View {
        
        let assignments: [Assignment]
        @State private var placedFirstHeader = false
        
        var body: some View {
            VStack {
                ZStack {
                    Color(.secondarySystemBackground)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0 ..< assignments.count) { index in
                            if index < assignments.count {
                                assignmentItem(assignments: assignments, index: index)
                            }
                        }
                    }
                }
                .frame(minWidth: .infinity, minHeight: .infinity)
            }
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
}



@main
struct AssignmentWidget: Widget {
    let kind: String = "AssignmentWidget"
    //let provider = Provider(moc: PersistenceController.shared.container.viewContext)
    let provider = Provider()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: provider) { entry in
            Assignment_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Assignments")
        .description("View your upcoming assignments")
        .supportedFamilies([.systemLarge])
    }
}

struct Assignment_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Assignment_WidgetEntryView(entry: Entry(date: Date(), assignments: Assignment.sampleAssignments()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
