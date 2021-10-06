//
//  WidgetView.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/30/21.
//

import SwiftUI
import Introspect
import BetterSafariView

enum SortMode: String, CaseIterable, Equatable {
    case date
    case course
    
    var id: String { self.rawValue.capitalized }
}

struct AssignmentList: View {
    @AppStorage("firstLaunch", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showLanding: Bool = true
    
    @State private var showingMeView = false
    
    @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var auth: String = ""
    @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
    @AppStorage("showLate", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showLate: Bool = true
    
    @State private var assignments: [Assignment] = []
    @State private var fetchState: FetchState = .loading
    
    @EnvironmentObject var courseArray: CourseArray
    @EnvironmentObject var hiddenAssignments: AssignmentArray
    
    @AppStorage("defaultSort", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var defaultSortMode: SortMode = .date
    
    @State private var sortMode: SortMode = .date
    
    enum FetchState {
        case success, loading, failure
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
                        TabView(selection: $sortMode) {
                            successView(assignments: assignments, fetchState: $fetchState, sortMode: .date, load: load)
                                .tag(SortMode.date)
                            successView(assignments: assignments, fetchState: $fetchState, sortMode: .course, load: load)
                                .tag(SortMode.course)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .ignoresSafeArea(.all)
                        .id(assignments)
                    } else if assignments.isEmpty && !courseArray.courses.isEmpty {
                        VStack {
                            Text("You don't have any assignments due!")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            Button(action: {
                                Task { await load() }
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
                                Task { await load() }
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
                        if !showLanding {
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
                                Task { await load() }
                            }) {
                                Text("\(Image(systemName: "arrow.clockwise")) Refresh")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                    .offset(y: -40)
                    .foregroundColor(.secondary)
                    
                }
            }
            .fullScreenCover(isPresented: $showLanding, onDismiss: { Task { await load() } } ) {
                BoardingView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Assignments")
                        .font(.title)
                        .bold()
                        .padding(.vertical)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundColor(.white)
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                
                    Picker("Sort Mode", selection: $sortMode.animation()) {
                        ForEach(SortMode.allCases, id: \.self) {
                            Text($0.id)
                        }
                    }
                    .labelsHidden()
                    .scaleEffect(0.8, anchor: .trailing)
                    .disabled(fetchState != .success)
                    .pickerStyle(InlinePickerStyle())
                    
                    MeButton(showingMeView: $showingMeView)
                }
            }
            .sheet(isPresented: $showingMeView) {
                MeView()
                    .environmentObject(courseArray)
                    .environmentObject(hiddenAssignments)
            }
        }
        .task {
            sortMode = defaultSortMode
            await load()
        }
    }
    
    func load(resetState: Bool = true) async {
        if resetState {
            fetchState = .loading
        }
        
        do {
            let todoAssignments = try await asyncFetchAssignments(auth: auth, prefixes: prefixes)
            var fetchedAssignments: [Assignment] = []
            for assignment in todoAssignments {
                if let newAssignment = createAssignment(courseArray: courseArray, assignment) {
                    if showLate {
                        fetchedAssignments.append(newAssignment)
                    } else if newAssignment.due > Date() {
                        fetchedAssignments.append(newAssignment)
                    }
                }
            }
            self.assignments = fetchedAssignments
            self.fetchState = .success
            
        } catch {
            fetchState = .failure
            print("error: \(error)")
        }
    }
    
    struct successView: View {
        let assignments: [Assignment]
        @Binding var fetchState: FetchState
        
        let sortMode: SortMode
        
        @State private var hasAnimated = false
        
        @AppStorage("hideScrollBar", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var hideScrollBar: Bool = true
        
        @EnvironmentObject var courseArray: CourseArray
        @EnvironmentObject var hiddenAssignments: AssignmentArray
        
        let load: (Bool) async -> Void
        
        var splitAssignments: [[Assignment]] {
            if sortMode == .date {
                let sortedAssignments = assignments.sorted()
                if sortedAssignments.count > 0 {
                    var assy: [[Assignment]] = []
                    var shortAssy: [Assignment] = []
                    var lastDate = assignments[0].due
                    
                    for assignment in sortedAssignments {
                        if assignment.due.getYearDay() != lastDate.getYearDay() {
                            assy.append(shortAssy)
                            shortAssy = []
                        }
                        
                        if !hiddenAssignments.assignments.contains(where: { $0.name == assignment.name && $0.url == assignment.url }) {
                            shortAssy.append(assignment)
                        }
                        
                        lastDate = assignment.due
                    }
                    assy.append(shortAssy)
                    
                    return assy
                    
                } else { return [] }
            } else {
                let sortedAssignments = assignments.sorted {
                    if $0.courseOrder == $1.courseOrder {
                        return $0.due < $1.due
                    } else {
                        return $0.courseOrder < $1.courseOrder
                    }
                }
                if sortedAssignments.count > 0 {
                    var assy: [[Assignment]] = []
                    var shortAssy: [Assignment] = []
                    var lastOrder = assignments[0].courseOrder
                    
                    for assignment in sortedAssignments {
                        if assignment.courseOrder != lastOrder {
                            assy.append(shortAssy)
                            shortAssy = []
                        }
                        
                        if !hiddenAssignments.assignments.contains(where: { $0.name == assignment.name && $0.url == assignment.url }) {
                            shortAssy.append(assignment)
                        }
                        
                        lastOrder = assignment.courseOrder
                    }
                    assy.append(shortAssy)
                    
                    return assy
                    
                } else { return [] }
            }
        }
        
        var body: some View {
            ScrollViewReader { proxy in
                List {
                    ForEach(Array(zip(splitAssignments.indices, splitAssignments)), id: \.0) { index, assignmentArray in
                        if !assignmentArray.isEmpty {
                            Section {
                                assignmentGroup(hasAnimated: $hasAnimated, sortMode: sortMode, assignmentArray: assignmentArray, index: index)
                                    .listRowSeparator(.hidden)
                                    .id(index)
                                
                            }
                        }
                    }
                }
                .id(assignments)
                .listStyle(PlainListStyle())
                .introspectTableView { tableView in
                    tableView.showsVerticalScrollIndicator = !hideScrollBar
                }
                .onChange(of: sortMode) { _ in proxy.scrollTo(0) }
                .refreshable {
                    await load(false)
                }
            }
        }
        
        func scrollToToday(proxy: ScrollViewProxy) {
            if sortMode == .date {
                for (index, assignmentGroup) in Array(zip(splitAssignments.indices, splitAssignments)) {
                    if !assignmentGroup.isEmpty {
                        let due = assignmentGroup[0].due
                        if Calendar.current.numberOfDaysBetween(Date(), and: due) >= 0 {
                            proxy.scrollTo(index, anchor: .top)
                            break
                        }
                    }
                }
            }
        }
        
        struct assignmentGroup: View {
            @AppStorage("exactHeaders", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var exactHeaders: Bool = false
            
            @Binding var hasAnimated: Bool
            let sortMode: SortMode
            let assignmentArray: [Assignment]
            let index: Int
            
            @EnvironmentObject var courseArray: CourseArray
            
            @State private var specificDate = false
            
            @State private var yOffset: CGFloat = 200
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
                            Button {
                                if sortMode == .date {
                                    specificDate.toggle()
                                }
                            } label: {
                                Text(sortMode == .date ? assignmentArray[0].createTitleText(exactHeaders: exactHeaders, isSpecific: specificDate) : courseArray.courses[assignmentArray[0].courseOrder].name)
                                    .foregroundColor(sortMode == .date ? .primary : assignmentArray[0].color)
                                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                                    .padding(.bottom, 7)
                            }
                            .buttonStyle(.plain)
                            
                            ForEach(assignmentArray, id: \.self) { assignment in
                                assignmentItem(assignment: assignment, sortMode: sortMode)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .padding(.vertical, 7)
                    .padding(.leading, 4)
                }
                .offset(x: 0, y: yOffset)
                .opacity(opacity)
                .onAppear {
                    if !hasAnimated {
                        withAnimation(.default.delay(delay * Double(index)).speed(speed)) {
                            yOffset = 0
                            opacity = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            hasAnimated = true
                        }
                    } else {
                        yOffset = 0
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
            
            struct assignmentItem: View {
                @AppStorage("exactHeaders", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var exactHeaders: Bool = false
                
                let assignment: Assignment
                let sortMode: SortMode
                
                @EnvironmentObject var hiddenAssignments: AssignmentArray
                
                @State private var showSafari = false
                
                var timeFormatter: DateFormatter {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .none
                    formatter.timeStyle = .short
                    return formatter
                }
                
                var body: some View {
                    Menu {
                        Button {
                            showSafari = true
                        } label: {
                            Image(systemName: "safari")
                            Text("Open Assignment")
                        }
                        Button {
                            hiddenAssignments.assignments.append(assignment)
                        } label: {
                            Image(systemName: "eye.slash")
                            Text("Hide Assignment")
                        }
                    } label: {
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
                                    Text(sortMode == .date ? timeFormatter.string(from: assignment.due) : assignment.createTitleText(exactHeaders: exactHeaders))
                                        .contrast(0.5)
                                    
                                    Text(" • ")
                                    
                                    Text(sortMode == .date ? assignment.courseName : timeFormatter.string(from: assignment.due))
                                        .foregroundColor(assignment.color)
                                }
                                .font(.system(size: 8, weight: .semibold, design: .default))
                                .lineLimit(1)
                                .offset(x: 2, y: 0)
                            }
                            
                            Spacer()
                        }
                        .foregroundColor(.primary)
                        .offset(x: 10, y: 0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .safariView(isPresented: $showSafari) {
                        SafariView(url: assignment.url)
                    }
                }
            }
        }
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentList(auth: "", prefixes: [""])
            .preferredColorScheme(.dark)
    }
}
