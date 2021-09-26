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
    @AppStorage("1.1Sheet", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showUpdate: Bool = true
    @AppStorage("firstLaunch", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showLanding: Bool = true
    @State private var updateSheet = false
    
    let whatsNew: WhatsNew = WhatsNew(title: "What's new in Version 1.1", items: [
        WhatsNew.Item(title: "App Icons", subtitle: "13 new app icons! Check them out!", image: UIImage(systemName: "square.grid.3x3")),
        WhatsNew.Item(title: "Widget Features", subtitle: "The widget now has a built-in option to display late assignments.", image: UIImage(systemName: "square")),
        WhatsNew.Item(title: "Bug Fixes", subtitle: "Fixed bugs - the widget should now appear in iOS 14 (maybe?)", image: UIImage(systemName: "ant"))
    ])
    var whatsNewConfiguration: WhatsNewViewController.Configuration {
        var config = WhatsNewViewController.Configuration(theme: .darkBlue)
        config.itemsView.animation = .slideRight
        config.itemsView.contentMode = .top
        config.completionButton = .init(stringLiteral: "Done")
        config.backgroundColor = .secondarySystemBackground
        return config
    }
    
    var body: some View {
        AssignmentList()
            .environmentObject(courseArray)
            .sheet(isPresented: $updateSheet) {
                if !showLanding {
                    WhatsNewView(whatsNew: self.whatsNew, configuration: whatsNewConfiguration)
                }
            }
            .onAppear {
                if !showLanding && showUpdate {
                    updateSheet = true
                    showUpdate = false
                }
            }
            .tabItem {
                //Image(systemName: "checklist")
                //Image(systemName: "list.bullet.rectangle")
                Text("Assignments")
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
