//
//  Persistence.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/25/21.
//

import CoreData
import SwiftUI

class StorageProvider {
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "Courses")
        
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error.localizedDescription)")
            }
        }
    }
    
    func getAllCourses() -> [Course] {
        let fetchRequest: NSFetchRequest<Course> = Course.fetchRequest()
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch courses: \(error)")
            return []
        }
    }
}

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let c1 = Course(name: "Lit/Comp", code: 139580, context: viewContext)
        c1.uOrder = 0
        c1.uColor = Color(courseColors[0])
        let c2 = Course(name: "Government", code: 124901, context: viewContext)
        c2.uOrder = 1
        c2.uColor = Color(courseColors[1])
        let c3 = Course(name: "Economics", code: 125048, context: viewContext)
        c3.uOrder = 2
        c3.uColor = Color(courseColors[2])
        let c4 = Course(name: "Statistics", code: 121592, context: viewContext)
        c4.uOrder = 3
        c4.uColor = Color(courseColors[3])
        let c5 = Course(name: "Research", code: 138477, context: viewContext)
        c5.uOrder = 4
        c5.uColor = Color(courseColors[4])
        let c6 = Course(name: "Biology", code: 123360, context: viewContext)
        c6.uOrder = 5
        c6.uColor = Color(courseColors[5])
        let c7 = Course(name: "Computer Science", code: 131783, context: viewContext)
        c7.uOrder = 6
        c7.uColor = Color(courseColors[6])
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Assignment_Tracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
