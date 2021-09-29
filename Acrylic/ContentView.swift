//
//  ContentView.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/25/21.
//

import SwiftUI
import CoreData
import WhatsNewKitSwiftUI
import WhatsNewKit

struct ContentView: View {
    @ObservedObject var courseArray = CourseArray()
    @ObservedObject var hiddenAssignments = AssignmentArray(key: "hiddenAssignments")
    
    @AppStorage("1.2Sheet", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showUpdate: Bool = false
    @AppStorage("firstLaunch", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showLanding: Bool = true
    
    @State private var updateSheet = false
    
    var body: some View {
        AssignmentList()
            .environmentObject(courseArray)
            .environmentObject(hiddenAssignments)
            .sheet(isPresented: $updateSheet) {
                if !showLanding {
                    AcrylicWhatsNew()
                }
            }
            .onAppear {
                if !showLanding && showUpdate {
                    updateSheet = true
                    showUpdate = false
                }
            }
            .tabItem {
                Image(systemName: "checklist")
                Text("Assignments")
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
