//
//  GetCourses.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/31/21.
//

import SwiftUI

struct GetCourses: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) private var presentationMode
    
    @AppStorage("Auth") var auth: String = ""
    @AppStorage("prefixes") var prefixes: [String] = []
    @State private var courses: [CanvasCourse] = []
    @State private var fetchState: FetchState = .loading
    @State private var errorType: ErrorType = .none
    
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
                    SuccessView(courses: courses)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarTitle("Get Canvas Courses")
                        .navigationBarItems(leading: Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }.padding([.trailing]), trailing: Button("Add") {
                            addCourses()
                            presentationMode.wrappedValue.dismiss()
                        }.padding([.leading]).disabled(fetchState != .success))
                }
            }
        }
        .onAppear(perform: fetchCourses)
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
                Text("You can always edit them later.")
                    .font(.callout)
                    .italic()
                    .padding([.horizontal, .bottom])
                    .foregroundColor(.secondary)
                
                Divider()
                
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
                .padding([.horizontal, .bottom])
            }
        }
    }
    
    func fetchCourses() {
        var loadedPrefixes: [String] = []
        errorType = .none
        
        for prefix in prefixes {
            fetchState = .loading
            
            let urlString = "https://\(prefix).instructure.com/api/v1/courses?per_page=100&include[]=term&include[]=favorites&include[]=teachers"
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                fetchState = .failure
                errorType = .badURL
                return
            }
            var request = URLRequest(url: url)
            let auth = auth
            request.allHTTPHeaderFields = ["Authorization" : "Bearer " + auth]
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                loadedPrefixes.append(prefix)
                var isLastPrefix: Bool {
                    for prefix in prefixes {
                        if !loadedPrefixes.contains(prefix) {
                            return false
                        }
                    }
                    return true
                }
                
                if let response = response, let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 401 {
                        fetchState = .failure
                        errorType = .badAuth
                        return
                    }
                }
                
                if let data = data {
                    let decoder = JSONDecoder()
                    if let list = try? decoder.decode([CanvasCourse].self, from: data) {
                        for course in list {
                            if let term = course.term {
                                if let start = term.startDate, let end = term.endDate, let startDate = ISO8601DateFormatter().date(from: start), let endDate = ISO8601DateFormatter().date(from: end) {
                                    if Date() > startDate && Date() < endDate {
                                        courses.append(course)
                                    }
                                }
                            }
                        }
                        if courses.isEmpty {
                            for course in list {
                                if course.isFavorite ?? false {
                                    courses.append(course)
                                }
                            }
                        }
                        if courses.isEmpty {
                            for course in list {
                                courses.append(course)
                            }
                        }
                        
                        if isLastPrefix {
                            fetchState = .success
                        }
                    }
                } else {
                    fetchState = .failure
                    errorType = .badLoad
                    return
                }
            }.resume()
        }
    }
    
    func addCourses() {
        var order = 0
        var colorsAdded = 0
        for course in courses {
            guard let name = course.name else { return }
            let newCourse = Course(name: name, code: course.id, context: moc)
            
            newCourse.uOrder = order
            order += 1
            
            if let teachers = course.teachers {
                if teachers.count > 0 {
                    newCourse.uTeacher = teachers[0].name
                }
            }
            
            if colorsAdded < courseColors.count {
                newCourse.uColor = Color(courseColors[colorsAdded])
                colorsAdded += 1
            } else {
                newCourse.uColor = Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
            }
        }
        
        try? moc.save()
    }
}

struct GetCourses_Previews: PreviewProvider {
    static var previews: some View {
        GetCourses()
    }
}
