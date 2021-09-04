//
//  Assignment_TrackerApp.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/25/21.
//

import SwiftUI

@main
struct Assignment_TrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
