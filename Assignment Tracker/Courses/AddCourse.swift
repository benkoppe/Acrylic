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
                Section(header: Text("")) {
                    TextField("Name", text: $name)
                    TextField("Teacher (Optional)", text: $teacher)
                        .disableAutocorrection(true)
                    defaultsColorPicker(color: $color)
                }
                
                canvasInfo(code: $code)
                
                // TODO: add "Test" button that loads course info
            }
            .onAppear(perform: defaults)
            .navigationTitle("New Course")
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
        
        var body: some View {
            Section(header:
                HStack {
                    Text("Canvas Info")
                    Button(action: {
                        print("Canvas Info button pressed")
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
                                    .animation(.easeOut(duration: 0.2))
                            }
                        }
                    }
                }
            }
        }
        
        func colorsEqual(_ lhs: Color, _ rhs: Color) -> Bool {
            func roundrgba(_ color: Color) -> (red: Double, blue: Double, green: Double, alpha: Double) {
                let rgba = UIColor(color).rgba
                return (round(rgba.red * 1000), round(rgba.blue * 1000), round(rgba.green * 1000), round(rgba.alpha * 1000))
            }
            
            if roundrgba(lhs) == roundrgba(rhs) {
                return true
            } else {
                return false
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
