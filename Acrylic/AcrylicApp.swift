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
struct AcrylicApp: App {
    @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var auth: String = ""
    @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
    
    init () {
        UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBar().standardAppearance
        UINavigationBar.appearance().isTranslucent = true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .dynamicTypeSize(.medium)
                .onOpenURL { url in
                    print("Hello")
                    WidgetCenter.shared.reloadAllTimelines()
                    var str = url.absoluteString
                    str.removeFirst(9)
                    if let pageURL = URL(string: str) {
                        UIApplication.shared.open(pageURL)
                    }
                }
                .onChange(of: auth) { _ in
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .onChange(of: prefixes) { _ in
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
    }
}
