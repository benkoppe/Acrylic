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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    var str = url.absoluteString
                    str.removeFirst(9)
                    let pageURL = URL(string: str)!
                    UIApplication.shared.open(pageURL)
                }
        }
    }
}
