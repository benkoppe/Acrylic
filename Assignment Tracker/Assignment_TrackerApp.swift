//
//  Assignment_TrackerApp.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/25/21.
//

import SwiftUI
import CoreData
import WidgetKit

@main
struct Assignment_TrackerApp: App {
    init () {
        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBar().standardAppearance
        UINavigationBar.appearance().isTranslucent = true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .colorScheme(.dark)
                .onOpenURL { url in
                    var str = url.absoluteString
                    str.removeFirst(9)
                    let pageURL = URL(string: str)!
                    UIApplication.shared.open(pageURL)
                }
        }
    }
}
