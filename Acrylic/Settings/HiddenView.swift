//
//  HiddenView.swift
//  Acrylic
//
//  Created by Ben K on 9/28/21.
//

import SwiftUI

struct HiddenView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var hiddenAssignments: AssignmentArray
    
    @State private var clearAll: Bool = false
    @State private var search: String = ""
    
    var assignments: Dictionary<Date, [Assignment]> {
        if search == "" {
            return Dictionary(grouping: hiddenAssignments.assignments, by: { assignment in
                let due = Calendar.current.startOfDay(for: assignment.due)
                return due
            })
        } else {
            var filteredAssignments: [Assignment] = []
            for assignment in hiddenAssignments.assignments {
                if assignment.name.lowercased().contains(search.lowercased()) || assignment.courseName.lowercased().contains(search.lowercased()) {
                    filteredAssignments.append(assignment)
                }
            }
            return Dictionary(grouping: filteredAssignments, by: { assignment in
                let due = Calendar.current.startOfDay(for: assignment.due)
                return due
            })
        }
    }
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM dd, yyyy"
        return formatter
    }
    
    var body: some View {
        NavigationView {
            Group {
                if hiddenAssignments.assignments.isEmpty {
                    VStack(spacing: 10) {
                        Spacer()
                        Image(systemName: "eye.slash")
                            .font(.title)
                        Text("Hidden Assignments")
                            .font(.title)
                        Text("Tap an assignment to add it to the hidden assignments list. Anything in this list will never be displayed in the main screen or widget.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding()
                } else {
                    List {
                        ForEach(assignments.keys.sorted().reversed(), id: \.self) { key in
                            Section {
                                if let shortAssignments = assignments[key] {
                                    ForEach(shortAssignments, id: \.self) { assignment in
                                        AssignmentItem(assignment: assignment)
                                    }
                                    .onDelete { offsets in
                                        for offset in offsets {
                                            let assignment = shortAssignments[offset]
                                            if let index = hiddenAssignments.assignments.firstIndex(of: assignment) {
                                                hiddenAssignments.assignments.remove(at: index)
                                            }
                                        }
                                    }
                                }
                            } header: {
                                Text(key, formatter: formatter)
                            }
                        }
                    }
                    .searchable(text: $search)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Hidden")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        clearAll = true
                    } label: {
                        if hiddenAssignments.assignments.isEmpty {
                            Text("Clear")
                                .foregroundColor(.tertiaryLabel)
                        } else {
                            Text("Clear")
                                .foregroundColor(.red)
                        }
                    }
                    .disabled(hiddenAssignments.assignments.isEmpty)
                    
                    EditButton()
                        .disabled(hiddenAssignments.assignments.isEmpty)
                }
            }
            .alert(isPresented: $clearAll) {
                Alert(title: Text("Are you sure?"), message: Text("Do you really want to clear your hidden assignments?\n\nThis action cannot be undone."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Clear")) {deleteAll()})
            }
        }
    }
    
    func deleteAll() {
        hiddenAssignments.objectWillChange.send()
        hiddenAssignments.assignments = []
    }
    
    struct AssignmentItem: View {
        let assignment: Assignment
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(assignment.name)
                        .font(.system(.headline))
                        .lineLimit(1)
                    Text(assignment.courseName)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .font(.caption2)
                }
                Spacer()
            }
            .padding(5)
        }
    }
}

struct HiddenView_Previews: PreviewProvider {
    static var previews: some View {
        HiddenView()
    }
}
