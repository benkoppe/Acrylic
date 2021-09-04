//
//  CourseList.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/27/21.
//

import SwiftUI

struct CourseList: View {
    @EnvironmentObject var courseArray: CourseArray
    
    @State private var editMode: EditMode = .inactive
    @State private var deleteAllAlert = false
    
    @State private var showingAddSheet = false
    
    @State private var getCourses = false
    @State private var addCourse = false
    @State private var editCourse: Course?
    
    var body: some View {
        List {
            if courseArray.courses.count > 0 {
                ForEach(courseArray.courses, id: \.self.code) { course in
                    Button(action: {
                        editCourse = course
                    }) {
                        listItem(course: course)
                            .foregroundColor(.primary)
                    }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            } else {
                VStack(alignment: .leading) {
                    Text("No courses yet")
                        .font(.headline)
                    Text("Press the plus button to add your classes!")
                        .font(.caption)
                        .italic()
                }
                .padding(8)
            }
        }
        .onAppear(perform: manageOrder)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Classes")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                EditButton()
                    .disabled(courseArray.courses.count == 0)
            }
        }
        .navigationBarItems(trailing:
            Button(action: {
                if editMode == .active {
                    deleteAllAlert = true
                } else {
                    showingAddSheet = true
                }
            }) {
                Image(systemName: editMode == .active ? "trash" : "plus")
            }.foregroundColor(editMode == .active ? .red : .accentColor).padding([.vertical, .leading])
        )
        .environment(\.editMode, self.$editMode)
        .actionSheet(isPresented: $showingAddSheet) {
            ActionSheet(title: Text("How would you like to add your course(s)?"), buttons: [
                .default(Text("Automatically from Canvas")) { getCourses = true },
                .default(Text("Manually")) { addCourse = true },
                .cancel()])
        }
        .alert(isPresented: $deleteAllAlert) {
            Alert(title: Text("Are you sure?"), message: Text("Do you really want to delete all of your courses?\n\nThis action cannot be undone."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Delete All")) {deleteAll()})
        }
        .sheet(isPresented: $addCourse) {
            AddCourse()
        }
        .sheet(isPresented: $getCourses) {
            GetCourses()
        }
        .sheet(item: $editCourse) { course in
            AddCourse(course: course)
        }
    }
    
    func delete(at offsets: IndexSet) {
        courseArray.courses.remove(atOffsets: offsets)
        manageOrder()
    }
    
    func deleteAll() {
        editMode = .inactive
        courseArray.courses.removeAll()
    }
    
    func move(from source: IndexSet, to destination: Int) {
        courseArray.courses.move(fromOffsets: source, toOffset: destination)
        manageOrder()
    }
    
    func manageOrder() {
        var currentOrder = 0
        for course in courseArray.courses {
            course.order = currentOrder
            currentOrder += 1
        }
    }
    
    struct listItem: View {
        @ObservedObject var course: Course
        
        var body: some View {
            HStack {
                Text(String("\u{007C}"))
                    .font(.system(size: 40, design: .rounded))
                    .foregroundColor(course.color)
                    .offset(x: 0, y: -2.5)
                
                VStack(alignment: .leading) {
                    Text("\(course.name)")
                        .font(.system(size: 22, weight: .regular, design: .rounded))
                        .foregroundColor(course.color)
                        .lineLimit(1)
                    if let teacher = course.teacher {
                        if teacher != "" {
                            Text("\(teacher)")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(course.color)
                                .contrast(0.2)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .renderingMode(.template)
                    .padding(.trailing, 10)
                    .opacity(0.5)
            }
            .id(UUID())
            .padding(.vertical, 3)
            //.padding(.horizontal, 5)
        }
    }
}

struct CourseList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CourseList()
        }
    }
}
