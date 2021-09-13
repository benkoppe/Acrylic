//
//  WidgetView.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/30/21.
//

import SwiftUI
import Introspect

struct AssignmentList: View {
    @State private var showingMeView = false
    @State private var showingSettingsView = false
    
    @State private var doneFetching = false
    
    @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var auth: String = ""
    @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var prefixes: [String] = []
    @State private var assignments: [Assignment] = []
    @State private var fetchState: FetchState = .loading
    @State private var errorType: ErrorType = .none
    
    @EnvironmentObject var courseArray: CourseArray
    
    var sortModes = ["Date", "Course"]
    @State private var sortMode = "Date"
    
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
            Group {
                switch fetchState {
                
                case .success:
                    successView(assignments: $assignments)
                    
                case .loading:
                    ProgressView("Loading Assignments...")
                        .offset(y: -40)
                    
                default:
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    //Text("\(Image(systemName: "paintbrush")) Assignments")
                    Text("Assignments")
                        .font(.title)
                        .bold()
                        .padding(.vertical)
                        .gradientForeground(colors: [.red, .orange, .yellow, .green, .blue, .purple])
                   /* LinearGradient(gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]), startPoint: .leading, endPoint: .trailing)
                        .mask(
                            Text("Assignments")
                                .font(.title2)
                                .bold()
                                .padding(.vertical)
                                .frame(width: 200, height: 100, alignment: .leading)
                        )
                        .frame(width: 200, height: 100, alignment: .leading)*/
                }
                /*ToolbarItem(placement: .navigationBarLeading) {
                    Picker("Sort Mode", selection: $sortMode) {
                        ForEach(sortModes, id: \.self) {
                            Text($0)
                        }
                    }
                    .labelsHidden()
                }*/
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Picker("Sort Mode", selection: $sortMode) {
                        ForEach(sortModes, id: \.self) {
                            Text($0)
                        }
                    }
                    .labelsHidden()
                    .scaleEffect(0.8)
                    
                    Button(action: {
                        showingMeView = true
                    }) {
                        Image(systemName: "person.crop.circle")
                            .font(.callout)
                    }
                }
            }
            .sheet(isPresented: $showingMeView) {
                MeView()
                    .environmentObject(courseArray)
            }
        }
        .onAppear(perform: fetchAssignments)
    }
    
    struct successView: View {
        @Binding var assignments: [Assignment]
        
        @ObservedObject private var refreshController = AssignmentRefresh()
        
        class AssignmentRefresh: ObservableObject {
            @Published var controller: UIRefreshControl
            @Published var shouldReload = false
            
            init() {
                controller = UIRefreshControl()
                controller.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
            }
            
            @objc func handleRefresh() {
                print("refreshing now...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.controller.endRefreshing()
                    self.shouldReload = true
                }
            }
        }
        
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
            List {
                ForEach(splitAssignments, id: \.self) { assignmentArray in
                    Section {
                        ZStack {
                            Color("WidgetBackground")
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 15)
                                )
                                .padding(.vertical, 7)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(createTitleText(for: assignmentArray[0].due))
                                        //.font(.system(.title, design: .rounded))
                                        .font(.system(size: 25, weight: .semibold, design: .rounded))
                                        .foregroundColor(.gray)
                                        .brightness(0.5)
                                        .padding(.bottom, 7)
                                    
                                    ForEach(assignmentArray, id: \.self) { assignment in
                                        assignmentItem(assignment: assignment)
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                            .padding(.vertical, 7)
                            .padding(.leading, 4)
                        }
                        .introspectTableViewCell { cell in
                            cell.backgroundColor = .clear
                            cell.separatorInset = .zero
                            cell.clipsToBounds = true
                            cell.layer.borderWidth = 0
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .introspectTableView { tableView in
                tableView.refreshControl = refreshController.controller
                tableView.separatorStyle = .none
                tableView.separatorColor = .clear
                tableView.separatorInset = .zero
            }
            .onChange(of: refreshController.shouldReload) { value in
                print(value)
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
        
        struct assignmentItem: View {
            let assignment: Assignment
            
            var timeFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                return formatter
            }
            
            var body: some View {
                
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
                .buttonStyle(PlainButtonStyle())
                
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
        if prefixes.isEmpty {
            fetchState = .failure
            return
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
