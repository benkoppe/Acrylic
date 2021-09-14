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
    @ObservedObject var courseArray = CourseArray()
    
    func placeholder(in context: Context) -> Entry {
        return Entry(date: Date(), result: .success(Assignment.sampleAssignments()))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        if !context.isPreview {
            fetchAssignments() { result in
                let entry = Entry(date: Date(), result: result)
                completion(entry)
            }
        } else {
            let entry = Entry(date: Date(), result: .success(Assignment.sampleAssignments()))
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 1, to: Date())!
        
        if !context.isPreview {
            fetchAssignments() { result in
                let entry = Entry(date: Date(), result: result)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        } else {
            let entry = Entry(date: Date(), result: .success(Assignment.sampleAssignments()))
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
        
    }
    
    func fetchAssignments(completion: @escaping (Result<[Assignment], FetchError>) -> Void) {
        var assignments: [Assignment] = []
        var loadedPrefixes: [String] = []
        
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
                    if httpResponse.statusCode == 404 {
                        completion(.failure(.badPrefix))
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

struct Entry: TimelineEntry {
    let date: Date
    let result: Result<[Assignment], FetchError>
}

struct Assignment_WidgetEntryView: View {
    var entry: Entry
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM dd"
        return formatter
    }
    
    var body: some View {
        switch entry.result {
        
        case .success(let assignments):
            if assignments.count > 0 {
                successView(assignments: assignments)
            } else {
                Text("No assignments!")
            }
            
        case .failure:
            VStack {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 40))
                    .padding(.horizontal, 5)
                    .foregroundColor(.red)
                Spacer()
                    .frame(height: 10)
                Text("An error occured. Please check your settings and internet connection, and try again.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(width: 300)
            }
            .offset(y: -40)
            .foregroundColor(.secondary)
            
        }
    }
    
    struct successView: View {
        
        @State private var hasStopped = false
        let assignments: [Assignment]
        
        var splitAssignments: [[Assignment]] {
            if assignments.count > 0 {
                var assy: [[Assignment]] = []
                var shortAssy: [Assignment] = []
                var lastDate = assignments[0].due
                
                for assignment in assignments {
                    if assignment.due.getYearDay() != lastDate.getYearDay() {
                        assy.append(shortAssy)
                        shortAssy = []
                    }
                    shortAssy.append(assignment)
                    lastDate = assignment.due
                }
                assy.append(shortAssy)
                
                return assy
                
            } else { return [] }
        }
        
        var body: some View {
            ZStack {
                Color("WidgetBackground")
                
                pfp()
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                
                GeometryReader { geo in
                    VStack(alignment: .leading, spacing: 0) {
                        let sizeFittedAssignments = sizeFittedAssignments(proxy: geo)
                        
                        ForEach(0 ..< sizeFittedAssignments.count) { index in
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(createTitleText(for: splitAssignments[index][0].due))
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(.gray)
                                        .brightness(0.5)
                                        .frame(height: 30)
                                    
                                    ForEach(0 ..< sizeFittedAssignments[index].count, id: \.self) { smallIndex in
                                        assignmentItem(assignment: sizeFittedAssignments[index][smallIndex])
                                    }
                                }
                                Spacer()
                            }
                        }
                        
                        let count = sizeFittedAssignments.count - 1
                        if sizeFittedAssignments[count].last != splitAssignments[count].last {
                            moreItem(assignmentsLeft: splitAssignments[count].count - sizeFittedAssignments[count].count)
                        }
                    }
                }
                .padding()
                .padding(.top, 3)
            }
        }
        
        
        func createTitleText(for date: Date) -> String {
            let day = date.getYearDay()
            var shortFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                return formatter
            }
            var formatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d"
                return formatter
            }
            
            if day == Date().getYearDay() {
                return "Today"
            } else if day == (Calendar.current.date(byAdding: .day, value: 1, to: Date())!).getYearDay() {
                return "Tomorrow"
            } else if (Calendar.current.date(byAdding: .day, value: 1, to: Date())!).getYearDay() - day < 7 {
                return shortFormatter.string(from: date)
            } else {
                return formatter.string(from: date)
            }
        }
        
        func sizeFittedAssignments(proxy: GeometryProxy) -> [[Assignment]] {
            var sizeFittedArray: [[Assignment]] = []
            var sizeUsed = 0
            let totalSize = Int(proxy.size.height)
            
            for assignmentArray in splitAssignments {
                sizeUsed += ItemType.title.rawValue
                if sizeUsed + ItemType.more.rawValue > totalSize {
                    break
                }
                
                var addArray: [Assignment] = []
                for assignment in assignmentArray {
                    sizeUsed += ItemType.item.rawValue
                    if sizeUsed + ItemType.more.rawValue > totalSize {
                        if assignment == assignmentArray.last && sizeUsed < totalSize {
                            addArray.append(assignment)
                        }
                        break
                    }
                    addArray.append(assignment)
                }
                sizeFittedArray.append(addArray)
            }
            
            return sizeFittedArray
        }
        
        enum ItemType: Int {
            case title = 30
            case item = 40
            case more = 20
        }
        
        struct pfp: View {
            @AppStorage("pfp", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var pfp: Data?
            @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var prefixes: [String] = []
            
            var pfpImage: Image {
                let defaults = UserDefaults.init(suiteName: "group.com.benk.assytrack")
                if let data = defaults?.data(forKey: "pfp"), let image = UIImage(data: data) {
                    return Image(uiImage: image)
                } else {
                    return Image(systemName: "person.crop.circle")
                }
            }
            
            var body: some View {
                VStack {
                    HStack {
                        Spacer()
                        if !prefixes.isEmpty {
                            Link(destination: URL(string: "widget://https://\(prefixes[0]).instructure.com/")!) {
                                pfpImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .clipShape(Circle())
                            }
                        } else {
                            pfpImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
            }
        }
        
        struct assignmentItem: View {
            let assignment: Assignment
            
            var timeFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                return formatter
            }
            
            var body: some View {
                
                HStack(alignment: .center, spacing: 0) {
                    Spacer().frame(width: 7)
                    
                    Link(destination: URL(string: "widget://\(assignment.url)")!) {
                        
                        HStack(alignment: .center, spacing: 0) {
                            
                            Text(String("\u{007C}"))
                                .font(.system(size: 35, weight: .semibold, design: .rounded))
                                .foregroundColor(assignment.color)
                                .offset(y: -2)
                                //.padding(.leading, 5)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(assignment.name)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .lineLimit(1)
                                    .padding(.bottom, 1)
                                
                                HStack(spacing: 0) {
                                    Text(timeFormatter.string(from: assignment.due))
                                    .contrast(0.5)
                                    
                                    Text(" • ")
                                    
                                    Text(assignment.courseName)
                                        .foregroundColor(assignment.color)
                                }
                                .font(.system(size: 7, weight: .semibold, design: .default))
                                .lineLimit(1)
                                .offset(x: 2, y: 0)
                            }
                            .padding(.top, 1)
                            
                        }
                        .foregroundColor(.primary)
                        
                    }
                    
                    Spacer()
                }
                .offset(x: 1)
                .frame(height: 40)
                
            }
        }
        
        struct moreItem: View {
            let assignmentsLeft: Int
            
            var body: some View {
                HStack(alignment: .center, spacing: 0) {
                    Spacer().frame(width: 7)
                    
                    Link(destination: URL(string: "widget://FRONTPAGE")!) {
                        
                        HStack(alignment: .center, spacing: 0) {
                            
                            Text(String("\u{007C}"))
                                .font(.system(size: 23, weight: .semibold, design: .rounded))
                                .offset(y: -2)
                                //.padding(.leading, 5)
                            
                            Text("\(assignmentsLeft) more assignment\(assignmentsLeft == 1 ? "" : "s")")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                                .padding(.vertical, 1)
                                .padding(.leading, 2)
                            
                        }
                        .padding(.top, 10)
                        .foregroundColor(.secondary)
                        
                    }
                    
                    Spacer()
                }
                .offset(x: 4)
                .frame(height: 17)
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
                .preferredColorScheme(.dark)
                .colorScheme(.dark)
        }
        .configurationDisplayName("Assignments")
        .description("View your upcoming assignments")
        .supportedFamilies([.systemLarge])
    }
}

struct Assignment_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Assignment_WidgetEntryView(entry: Entry(date: Date(), result: .success(Assignment.sampleAssignments())))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .preferredColorScheme(.dark)
    }
}
