//
//  WidgetView.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/30/21.
//

import SwiftUI
import Introspect

struct AssignmentList: View {
    @AppStorage("firstLaunch", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showLanding: Bool = true
    //@State private var showLanding = false
    
    @State private var showingMeView = false
    @State private var showingSettingsView = false
    
    @State private var doneFetching = false
    
    @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var auth: String = ""
    @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
    @AppStorage("showLate", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showLate: Bool = true
    @State private var assignments: [Assignment] = []
    @State private var fetchState: FetchState = .loading
    
    @EnvironmentObject var courseArray: CourseArray
    
    enum SortMode: String, CaseIterable, Equatable {
        case date
        case course
        
        var id: String { self.rawValue.capitalized }
    }
    var sortModes = ["Date", "Course"]
    @State private var sortMode: SortMode = .date
    @State private var sortedMode: SortMode = .date
    
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
                    if !assignments.isEmpty && !courseArray.courses.isEmpty {
                        successView(assignments: $assignments, fetchState: $fetchState, sortMode: $sortedMode)
                    } else if assignments.isEmpty && !courseArray.courses.isEmpty {
                        VStack {
                            Text("You don't have any assignments due!")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            Button(action: {
                                load()
                            }) {
                                Text("\(Image(systemName: "arrow.clockwise")) Refresh")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                    .padding()
                            }
                        }
                        .padding()
                    } else {
                        VStack {
                            Text("You don't have any courses added yet.\n\nPlease add some with the button on the top left.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            Button(action: {
                                load()
                            }) {
                                Text("\(Image(systemName: "arrow.clockwise")) Refresh")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                    .padding()
                            }
                        }
                        .padding()
                    }
                    
                case .loading:
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    
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
                        Spacer()
                            .frame(height: 10)
                        Button(action: {
                            load()
                        }) {
                            Text("\(Image(systemName: "arrow.clockwise")) Refresh")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    .offset(y: -40)
                    .foregroundColor(.secondary)
                    
                }
            }
            .fullScreenCover(isPresented: $showLanding, onDismiss: { load() }) {
                BoardingView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    //Text("\(Image(systemName: "paintbrush")) Assignments")
                    Text("Assignments")
                        .font(.title)
                        .bold()
                        .padding(.vertical)
                        .fixedSize(horizontal: true, vertical: false)
                        //.gradientForeground(colors: [.red, .orange, .yellow, .green, .blue, .purple])
                        .foregroundColor(.white)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Picker("Sort Mode", selection: $sortMode) {
                        ForEach(SortMode.allCases, id: \.self) {
                            Text($0.id)
                        }
                    }
                    .labelsHidden()
                    .scaleEffect(0.8)
                    .offset(x: 05, y: 0)
                    .disabled(fetchState != .success)
                    .pickerStyle(InlinePickerStyle())
                    
                    Button(action: {
                        showingMeView = true
                    }) {
                        Image(systemName: "person.crop.circle")
                            .font(.body)
                    }
                }
            }
            .sheet(isPresented: $showingMeView, onDismiss: {
                if fetchState == .loading { load() }
            }) {
                MeView()
                    .environmentObject(courseArray)
            }
            .onChange(of: sortMode) { value in
                var arr = assignments
                switch sortMode {
                case .date:
                    arr.sort()
                case .course:
                    arr.sort {
                        if $0.courseOrder == $1.courseOrder {
                            return $0.due < $1.due
                        } else {
                            return $0.courseOrder < $1.courseOrder
                        }
                    }
                }
                assignments = arr
                sortedMode = sortMode
            }
        }
        .onAppear { load() }
    }
    
    func getCourseColors() -> [Color] {
        var arr: [Color] = []
        for course in courseArray.courses {
            arr.append(course.color)
        }
        if arr.isEmpty {
            return [.primary]
        }
        return arr
    }
    
    func load() {
        fetchState = .loading
        fetchAssignments(auth: auth, prefixes: prefixes) { result in
            switch result {
            case .success(let assignments):
                var arr: [Assignment] = []
                for assignment in assignments {
                    if let newAssignment = createAssignment(courseArray: courseArray, assignment) {
                        if showLate {
                            arr.append(newAssignment)
                        } else if newAssignment.due > Date() {
                            arr.append(newAssignment)
                        }
                    }
                }
                switch sortMode {
                case .date:
                    arr.sort()
                case .course:
                    arr.sort {
                        if $0.courseOrder == $1.courseOrder {
                            return $0.due < $1.due
                        } else {
                            return $0.courseOrder < $1.courseOrder
                        }
                    }
                }
                self.assignments = arr
                self.fetchState = .success
                
            case .failure(let error):
                self.fetchState = .failure
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    struct successView: View {
        @Binding var assignments: [Assignment]
        @Binding var fetchState: FetchState
        @Binding var sortMode: SortMode
        
        @State private var hasAnimated = false
        
        @ObservedObject private var refreshController = AssignmentRefresh()
        
        @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var auth: String = ""
        @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
        @AppStorage("showLate", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showLate: Bool = true
        
        @EnvironmentObject var courseArray: CourseArray
        
        class AssignmentRefresh: ObservableObject {
            @Published var controller: UIRefreshControl
            @Published var shouldReload = false
            
            init() {
                controller = UIRefreshControl()
                controller.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
            }
            
            @objc func handleRefresh() {
                self.shouldReload = true
            }
        }
        
        var splitAssignments: [[Assignment]] {
            if sortMode == .date {
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
            } else {
                if assignments.count > 0 {
                    var assy: [[Assignment]] = []
                    var shortAssy: [Assignment] = []
                    var lastOrder = assignments[0].courseOrder
                    
                    for assignment in assignments {
                        if assignment.courseOrder != lastOrder {
                            assy.append(shortAssy)
                            shortAssy = []
                        }
                        
                        shortAssy.append(assignment)
                        
                        lastOrder = assignment.courseOrder
                    }
                    assy.append(shortAssy)
                    
                    return assy
                    
                } else { return [] }
            }
        }
        
        var body: some View {
            List {
                ForEach(Array(zip(splitAssignments.indices, splitAssignments)), id: \.0) { index, assignmentArray in
                    Section {
                        assignmentGroup(hasAnimated: $hasAnimated, sortMode: $sortMode, assignmentArray: assignmentArray, index: index)
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
                fetchAssignments(auth: auth, prefixes: prefixes) { result in
                    switch result {
                    case .success(let assignments):
                        var arr: [Assignment] = []
                        for assignment in assignments {
                            if let newAssignment = createAssignment(courseArray: courseArray, assignment) {
                                if showLate {
                                    arr.append(newAssignment)
                                } else if newAssignment.due > Date() {
                                    arr.append(newAssignment)
                                }
                            }
                        }
                        switch sortMode {
                        case .date:
                            arr.sort()
                        case .course:
                            arr.sort {
                                if $0.courseOrder == $1.courseOrder {
                                    return $0.due < $1.due
                                } else {
                                    return $0.courseOrder < $1.courseOrder
                                }
                            }
                        }
                        self.assignments = arr
                        endRefresh()
                        
                    case .failure(let error):
                        endRefresh()
                        fetchState = .failure
                        print("Error: \(error.localizedDescription)")
                        
                    }
                }
            }
        }
        
        func endRefresh() {
            DispatchQueue.main.async {
                refreshController.shouldReload = false
                refreshController.controller.endRefreshing()
            }
        }
        
        struct assignmentGroup: View {
            @Binding var hasAnimated: Bool
            @Binding var sortMode: SortMode
            let assignmentArray: [Assignment]
            let index: Int
            @EnvironmentObject var courseArray: CourseArray
            
            @State private var offset: CGFloat = 200
            @State private var opacity: Double = 0
            let delay: Double = 0.05
            let speed: Double = 0.5
            
            var body: some View {
                ZStack {
                    Color("WidgetBackground")
                        .clipShape(
                            RoundedRectangle(cornerRadius: 15)
                        )
                        .padding(.vertical, 7)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(sortMode == .date ? createDateTitleText(for: assignmentArray[0].due) : courseArray.courses[assignmentArray[0].courseOrder].name)
                                //.font(.system(.title, design: .rounded))
                                .foregroundColor(sortMode == .date ? .primary : assignmentArray[0].color)
                                .font(.system(size: 25, weight: .semibold, design: .rounded))
                                .padding(.bottom, 7)
                            
                            ForEach(assignmentArray, id: \.self) { assignment in
                                assignmentItem(assignment: assignment, sortMode: $sortMode)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .padding(.vertical, 7)
                    .padding(.leading, 4)
                }
                .offset(x: 0, y: offset)
                .opacity(opacity)
                .onAppear {
                    if !hasAnimated {
                        withAnimation(.default.delay(delay * Double(index)).speed(speed)) {
                            offset = 0
                            opacity = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            hasAnimated = true
                        }
                    } else {
                        offset = 0
                        opacity = 1
                    }
                }
                .introspectTableViewCell { cell in
                    cell.backgroundColor = .clear
                    cell.separatorInset = .zero
                    cell.clipsToBounds = false
                    cell.layer.borderWidth = 0
                }
            }
            
            func createDateTitleText(for date: Date) -> String {
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
                
                if date < Date() {
                    return formatter.string(from: date)
                } else if day == Date().getYearDay() {
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
                @Binding var sortMode: SortMode
                
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
                                    Text(sortMode == .date ? timeFormatter.string(from: assignment.due) : createDateText(for: assignment.due))
                                        .contrast(0.5)
                                    
                                    Text(" • ")
                                    
                                    Text(sortMode == .date ? assignment.courseName : timeFormatter.string(from: assignment.due))
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
                
                func createDateText(for date: Date) -> String {
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
                    
                    if date < Date() {
                        return formatter.string(from: date)
                    }else if day == Date().getYearDay() {
                        return "Today"
                    } else if day == (Calendar.current.date(byAdding: .day, value: 1, to: Date())!).getYearDay() {
                        return "Tomorrow"
                    } else if (Calendar.current.date(byAdding: .day, value: 1, to: Date())!).getYearDay() - day < 7 {
                        return shortFormatter.string(from: date)
                    } else {
                        return formatter.string(from: date)
                    }
                }
            }
        }
    }
    
    struct failureView: View {
        
        
        var body: some View {
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
                Spacer()
                    .frame(height: 10)
                Button(action: {
                    
                }) {
                    Text("\(Image(systemName: "arrow.clockwise")) Refresh")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .offset(y: -40)
            .foregroundColor(.secondary)
        }
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentList(auth: "26~yxSOVTuYIh0Fx9dMdm1VgaMXyv7VvCa1Ub7JHMZUhzJpakh254MmtBblpzmv7Gb9", prefixes: ["hsccsd"])
            .preferredColorScheme(.dark)
    }
}
