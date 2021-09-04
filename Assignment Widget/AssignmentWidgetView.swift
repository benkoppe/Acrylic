//
//  AssignmentWidgetView.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/3/21.
//

/*
import WidgetKit
import SwiftUI
import CoreData

struct AssignmentWidgetView: View {
    var entry: Entry
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM dd"
        return formatter
    }
    
    var body: some View {
        //switch fetchState {
        
        //case .success:
            successView(assignments: entry.assignments)
            
        /*default:
            ProgressView()
            
        }*/
    }
    
    struct successView: View {
        
        let assignments: [Assignment]
        @State private var placedFirstHeader = false
        
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
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
}


struct AssignmentWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentWidgetView(entry: Entry(date: Date(), assignments: Assignment.sampleAssignments()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

*/
