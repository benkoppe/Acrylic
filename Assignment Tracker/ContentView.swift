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
        AssignmentList()
            .environmentObject(courseArray)
            .tabItem {
                //Image(systemName: "checklist")
                //Image(systemName: "list.bullet.rectangle")
                Text("Assignments")
            }
        
        /*if #available(iOS 15.0, *) {
            ZStack {
                //Color.white
                ZStack {
                    LinearGradient(colors: [.cyan, .cyan, .pink, .white, .pink, .cyan, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                    //Color("WidgetBackground")
                    
                    Image(systemName: "checkmark.circle")
                        //.foregroundStyle(LinearGradient(colors: [.red, .red, .orange, .yellow, .green, .blue, .purple, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.black)
                        .font(.system(size: 200))
                }
                .frame(width: 240, height: 240)
            }
        } else {
            Text("My fault")
        }*/
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
