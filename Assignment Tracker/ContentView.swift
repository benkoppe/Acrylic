//
//  ContentView.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/25/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Course.order, ascending: true)]) private var courses: FetchedResults<Course>

    var body: some View {
        TabView {
            NavigationView {
                CourseList()
            }
            .tabItem {
                Image(systemName: "graduationcap")
                Text("Courses")
            }
            
            AssignmentList()
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
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
