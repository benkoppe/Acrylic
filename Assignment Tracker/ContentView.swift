//
//  ContentView.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/25/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var courseArray = CourseArray()
    
    var body: some View {
        TabView {
            NavigationView {
                CourseList()
                    .environmentObject(courseArray)
            }
            .tabItem {
                Image(systemName: "graduationcap")
                Text("Courses")
            }
            
            AssignmentList()
                .environmentObject(courseArray)
                .tabItem {
                    //Image(systemName: "checklist")
                    Image(systemName: "list.bullet.rectangle")
                    Text("Assignments")
                }
            
            Settings()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
