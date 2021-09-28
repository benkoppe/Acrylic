//
//  GetCourses.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/31/21.
//

import SwiftUI

struct GetCourses: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var auth: String = ""
    @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
    @State private var canvasCourses: [CanvasCourse] = []
    @State private var fetchState: FetchState = .loading
    @State private var errorType: ErrorType = .none
    
    @EnvironmentObject var courseArray: CourseArray
    
    enum FetchState {
        case success, loading, failure
    }
    enum ErrorType {
        case none, badLoad, badURL, badAuth
    }
    
    var body: some View {
        Group {
            switch fetchState {
            case .loading:
                LoadingView()
            case .failure:
                FailureView()
            case .success:
                NavigationView {
                    SuccessView(courses: canvasCourses)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarTitle("Get Canvas Courses")
                        .navigationBarItems(leading: Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }.padding([.trailing, .vertical]), trailing: Button("Add") {
                            addCourses()
                            presentationMode.wrappedValue.dismiss()
                        }.padding([.leading, .vertical]).disabled(fetchState != .success))
                }
            }
        }
        .onAppear(perform: loadCourses)
    }
    
    
    struct LoadingView: View {
        var body: some View {
            ProgressView("Loading Classes...")
        }
    }
    
    struct FailureView: View {
        var body: some View {
            VStack(alignment: .center) {
                Spacer()
                Text("An Error Occurred.")
                    .font(.title)
                    .padding(.horizontal)
                    .padding(.bottom, 2)
                Text("There was a problem with loading your Canvas.\nPlease try again later.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
    }
    
    struct SuccessView: View {
        
        let courses: [CanvasCourse]
        
        
        
        var body: some View {
            VStack {
                Text("Add These Courses?")
                    .font(.title2)
                    .padding(.top, 30)
                    .padding(.horizontal)
                Text("You can edit thier names and colors later.")
                    .font(.callout)
                    .italic()
                    .padding([.horizontal, .bottom])
                    .foregroundColor(.secondary)
                
                List {
                    ForEach(courses, id: \.self) { course in
                        VStack(alignment: .leading) {
                            if let teacher = course.teachers?[0] {
                                Text(course.name ?? "NAME NOT FOUND")
                                    .font(.title3)
                                    .lineLimit(1)
                                    .padding(.top, 1)
                                
                                Text(teacher.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .padding(.bottom, 1)
                            } else {
                                Text(course.name ?? "NAME NOT FOUND")
                                    .font(.title3)
                                    .lineLimit(1)
                                    .padding(.vertical, 1)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding([.horizontal, .bottom])
            }
        }
    }
    
    func loadCourses() {
        fetchState = .loading
        var fetchedPrefixes: [String] = []
        var fetchedCourses: [CanvasCourse] = []
        
        fetchCourses(auth: auth, prefixes: prefixes) { result in
            var thisFetchedCourses: [CanvasCourse] = []
            
            switch result {
            case .success((let prefix, let courses)):
                fetchedPrefixes.append(prefix)
                for course in courses {
                    if let term = course.term {
                        if let start = term.startDate, let end = term.endDate, let startDate = ISO8601DateFormatter().date(from: start), let endDate = ISO8601DateFormatter().date(from: end) {
                            if Date() > startDate && Date() < endDate {
                                thisFetchedCourses.append(course)
                            }
                        }
                    }
                }
                if thisFetchedCourses.isEmpty {
                    for course in courses {
                        if course.isFavorite ?? false {
                            thisFetchedCourses.append(course)
                        }
                    }
                }
                if thisFetchedCourses.isEmpty {
                    for course in courses {
                        thisFetchedCourses.append(course)
                    }
                }
                
                fetchedCourses += thisFetchedCourses
                
                if fetchedPrefixes.sorted() == prefixes.sorted() {
                    var removeIndices = IndexSet()
                    for enumCourse in fetchedCourses.enumerated() {
                        let code = String(enumCourse.element.id)
                        if code.hasPrefix("179010000000") {
                            removeIndices.update(with: enumCourse.offset)
                        }
                    }
                    fetchedCourses.remove(atOffsets: removeIndices)
                    
                    self.canvasCourses = fetchedCourses
                    fetchState = .success
                }
                
            case .failure(let error):
                self.fetchState = .failure
                print("Error: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func addCourses() {
        var order = 0
        
        var colorsAdded = 0
        var randomColorsAdded = 0
        let hues: [Hue] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        
        var arr: [Course] = []
        for course in canvasCourses {
            guard let name = course.name else { return }
            
            var teacher: String? = nil
            if let teachers = course.teachers {
                if teachers.count > 0 {
                    teacher = teachers[0].name
                }
            }
            
            var color = Color(randomColor(hue: hues[randomColorsAdded % hues.count], luminosity: .bright))
            
            if colorsAdded < courseColors.count {
                color = Color(courseColors[colorsAdded])
                colorsAdded += 1
            } else {
                randomColorsAdded += 1
            }
            
            let newCourse = Course(name: name, code: course.id, order: order, color: color, teacher: teacher)
            
            order += 1
            
            arr.append(newCourse)
        }
        
        courseArray.courses = arr
    }
}

struct GetCourses_Previews: PreviewProvider {
    static var previews: some View {
        GetCourses()
    }
}
