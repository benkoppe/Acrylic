//
//  CourseList.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/27/21.
//

import SwiftUI

struct CourseList: View {
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    @EnvironmentObject var courseArray: CourseArray
    
    @State private var editMode: EditMode = .inactive
    @State private var deleteAllAlert = false
    
    @State private var showingAddSheet = false
    
    @State private var getCourses = false
    @State private var addCourse = false
    @State private var editCourse: Course?
    
    var activeEditButton: Bool {
        return courseArray.courses.count == 0
    }
    
    var body: some View {
        List {
            Section(header:
                        HStack {
                EditButton()
                    .disabled(activeEditButton)
                    .environment(\.editMode, self.$editMode)
                Spacer()
                Button(action: {
                    if editMode == .active {
                        deleteAllAlert = true
                    } else {
                        showingAddSheet = true
                    }
                }) {
                    Image(systemName: editMode == .active ? "trash" : "plus")
                }.foregroundColor(editMode == .active ? .red : .accentColor)
            }.padding([.horizontal])
            ) {
                if courseArray.courses.count > 0 {
                    ForEach(courseArray.courses, id: \.self.code) { course in
                        Button(action: {
                            print("adljfakldjfklaj")
                            print(course.name)
                            editCourse = course
                        }) {
                            listItem(course: course, editMode: editMode)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.borderless)
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: move)
                    .listRowBackground(Color(.systemGroupedBackground))
                } else {
                    VStack(alignment: .leading) {
                        Text("No courses yet")
                            .font(.headline)
                        Text("Press the plus button to add your classes!")
                            .font(.caption)
                            .italic()
                    }
                    .padding(8)
                    .listRowBackground(Color(.systemGroupedBackground))
                }
            }
        }
        .background(Color(.black).ignoresSafeArea())
        .onAppear(perform: manageOrder)
        .onDisappear() {
            UITableView.appearance().backgroundColor = .systemBackground
        }
        .introspectTableView { tableView in
            if #available(iOS 15.0, *) {
                tableView.contentOffset = CGPoint(x: 0, y: -38)
            }
        }
        .listStyle(.insetGrouped)
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
        let editMode: EditMode
        
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
                
                if editMode == .inactive {
                    Image(systemName: "chevron.right")
                        .renderingMode(.template)
                        .padding(.trailing, 10)
                        .opacity(0.5)
                }
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
