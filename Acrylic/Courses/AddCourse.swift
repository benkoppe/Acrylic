//
//  AddCourse.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/27/21.
//

import SwiftUI

struct AddCourse: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject var courseArray: CourseArray
    var course: Course?
    
    @State private var name = ""
    @State private var teacher = ""
    @State private var code = ""
    @State private var order = 0
    @State private var color = Color("red")
    
    enum Style {
        case new, edit
    }
    let style: Style
    
    init() {
        self.style = .new
    }
    init(course: Course) {
        self.course = course
        self.style = .edit
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section() {
                    HStack {
                        TextField("Name", text: $name)
                    }
                    HStack {
                        TextField("Teacher (Optional)", text: $teacher)
                            .disableAutocorrection(true)
                    }
                    defaultsColorPicker(color: $color)
                }
                
                canvasInfo(code: $code)
                
                // TODO: add "Test" button that loads course info
            }
            .onAppear(perform: defaults)
            .navigationTitle(self.style == .edit ? "Edit Course" : "New Course")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.padding([.trailing, .vertical]), trailing: Button("Save") {
                saveData()
            }.padding([.leading, .vertical]))
        }
    }
    
    struct canvasInfo: View {
        @Binding var code: String
        @State private var showingInfo = false
        
        var body: some View {
            Section(header:
                HStack {
                    Text("Canvas Info")
                    Button(action: {
                        showingInfo = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
            ) {
                HStack {
                    TextField("Code", text: $code)
                        .keyboardType(.numberPad)
                }
            }
            .alert(isPresented: $showingInfo) {
                Alert(title: Text("Code Info"), message: Text("On Canvas, each course has its own unique code. You can find this code at the end of the course's home page.\n\nFor example, if the home url was instructure.com/courses/12345, the code would be 12345."), dismissButton: .cancel(Text("OK")))
            }
        }
    }
    
    struct defaultsColorPicker: View {
        @Binding var color: Color
        
        var body: some View {
            HStack {
                ColorPicker("Color", selection: self.$color)
                    .labelsHidden()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(courseColors, id: \.self) { color in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(color))
                                    .frame(width: 30, height: 20)
                                    .onTapGesture {
                                        self.color = Color(color)
                                    }
                                    .innerShadow(using: RoundedRectangle(cornerRadius: 10), width: 2)
                                    .opacity(!colorsEqual(self.color, Color(color)) ? 1 : 0.75)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .opacity(!colorsEqual(self.color, Color(color)) ? 0 : 1)
                                            .foregroundColor(.white)
                                            .font(.system(.callout, design: .rounded))
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
    }
    
    func defaults() {
        switch style {
        case .new:
            name = ""
            teacher = ""
            code = ""
            order = 0
            color = Color("red")
            
        case .edit:
            if let course = course {
                self.name = course.name
                
                if let teacher = course.teacher {
                    self.teacher = teacher
                } else {
                    self.teacher = ""
                }
                self.code = String(course.code)
                self.order = course.order
                self.color = course.color
            }
        }
    }
    
    func saveData() {
        if let code = Int(code) {
            var addTeacher: String? = nil
            if teacher.trimmingCharacters(in: .whitespacesAndNewlines) != "" { addTeacher = teacher }
            let newCourse = Course(name: name, code: code, order: order, color: color, teacher: addTeacher)
            
            switch style {
            case .new:
                courseArray.courses.append(newCourse)
                
            case .edit:
                if let course = course, let index = courseArray.courses.firstIndex(of: course) {
                    courseArray.courses[index].name = name
                    courseArray.courses[index].code = code
                    courseArray.courses[index].order = order
                    courseArray.courses[index].color = color
                    courseArray.courses[index].teacher = addTeacher
                    courseArray.save()
                }
            }
            
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AddCourse_Previews: PreviewProvider {
    static var previews: some View {
        AddCourse()
    }
}
