//
//  Assignment_Widget.swift
//  Assignment Widget
//
//  Created by Ben K on 9/3/21.
//

import WidgetKit
import SwiftUI
import CoreData
import Intents

struct Provider: IntentTimelineProvider {
    @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var auth: String = ""
    @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
    
    func placeholder(in context: Context) -> Entry {
        return Entry(date: Date(), result: .success(Assignment.sampleAssignments()), exactHeaders: false)
    }
    
    func getSnapshot(for configuration: AssignmentWidgetConfigurationIntent, in context: Context, completion: @escaping (Entry) -> Void) {
        if !context.isPreview {
            Task {
                let entry = await loadEntry(configuration: configuration)
                completion(entry)
            }
        } else {
            let entry = Entry(date: Date(), result: .success(Assignment.sampleAssignments()), exactHeaders: configuration.exactHeaders?.boolValue ?? false)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: AssignmentWidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        if !context.isPreview {
            Task {
                let entry = await loadEntry(configuration: configuration)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        } else {
            let entry = Entry(date: Date(), result: .success(Assignment.sampleAssignments()), exactHeaders: configuration.exactHeaders?.boolValue ?? false)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    func loadEntry(configuration: AssignmentWidgetConfigurationIntent) async -> Entry {
        do {
            let hiddenAssignments = AssignmentArray(key: "hiddenAssignments")
            let todoAssignments = try await asyncFetchAssignments(auth: auth, prefixes: prefixes)
            var fetchedAssignments: [Assignment] = []
            for assignment in todoAssignments {
                if let newAssignment = createAssignment(courseArray: CourseArray(), assignment) {
                    if !hiddenAssignments.assignments.contains(where: { $0.name == newAssignment.name && $0.url == newAssignment.url }) {
                        if configuration.showLate?.boolValue ?? false {
                            fetchedAssignments.append(newAssignment)
                        } else if newAssignment.due > Date() {
                            fetchedAssignments.append(newAssignment)
                        }
                    }
                }
            }
            
            fetchedAssignments.sort()
            let entry = Entry(date: Date(), result: Result<[Assignment], FetchError>.success(fetchedAssignments), exactHeaders: configuration.exactHeaders?.boolValue ?? false)
            return entry
        } catch {
            let entry = Entry(date: Date(), result: Result<[Assignment], FetchError>.failure(error as? FetchError ?? .badLoad), exactHeaders: configuration.exactHeaders?.boolValue ?? false)
            return entry
        }
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let result: Result<[Assignment], FetchError>
    let exactHeaders: Bool
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
                successView(assignments: assignments, exactHeaders: entry.exactHeaders)
            } else {
                Text("No assignments!")
                    .padding()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.primary)
            }
            
        case .failure:
            ZStack {
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
                .foregroundColor(.secondary)
            }
        }
    }
    
    struct successView: View {
        @State private var hasStopped = false
        let assignments: [Assignment]
        let exactHeaders: Bool
        
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
                                    Text(splitAssignments[index][0].createTitleText(exactHeaders: exactHeaders))
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
            @AppStorage("pfp", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var pfp: Data?
            @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
            
            var pfpImage: Image {
                let defaults = UserDefaults.init(suiteName: "group.com.benk.acrylic")
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
        IntentConfiguration(kind: kind, intent: AssignmentWidgetConfigurationIntent.self, provider: provider) { entry in
            Assignment_WidgetEntryView(entry: entry)
                .preferredColorScheme(.dark)
                .colorScheme(.dark)
                .widgetURL(URL(string: "widget://")!)
        }
        .configurationDisplayName("Assignments")
        .description("View your upcoming assignments")
        .supportedFamilies([.systemLarge])
    }
}

struct AssignmentWidget_Previews: PreviewProvider {
    static var previews: some View {
        Assignment_WidgetEntryView(entry: Entry(date: Date(), result: .success(Assignment.sampleAssignments()), exactHeaders: false))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .preferredColorScheme(.dark)
    }
}
