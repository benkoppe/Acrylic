//
//  Course+CoreDataProperties.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/25/21.
//
//

import Foundation
import CoreData
import SwiftUI

extension Course {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @NSManaged private var code: Int64
    @NSManaged private var name: String?
    @NSManaged private var teacher: String?
    @NSManaged public var order: Int16
    
    @NSManaged private var colorR: Double
    @NSManaged private var colorG: Double
    @NSManaged private var colorB: Double
    @NSManaged private var colorA: Double
    
    public var uName: String {
        get {
            return self.name ?? ""
        }
        set {
            self.name = newValue
        }
    }
    public var uTeacher: String {
        get {
            return self.teacher ?? ""
        }
        set {
            self.teacher = newValue
        }
    }
    public var uCode: Int {
        get {
            return Int(self.code)
        }
        set {
            self.code = Int64(newValue)
        }
    }
    public var uOrder: Int {
        get {
            return Int(self.order)
        } set {
            self.order = Int16(newValue)
        }
    }
    
    public var uColor: Color {
        get {
            return Color(red: colorR, green: colorG, blue: colorB, opacity: colorA)
        } set {
            let rgba = UIColor(newValue).rgba
            self.colorR = rgba.red
            self.colorG = rgba.green
            self.colorB = rgba.blue
            self.colorA = rgba.alpha
        }
    }

}

extension Course: Identifiable {
    
}

extension Course {
    
}

extension Course {
    convenience init(name: String, code: Int, order: Int, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.uName = name
        self.uCode = code
        self.uOrder = order
    }
    
    convenience init(name: String, code: Int, context: NSManagedObjectContext) {
        self.init(name: name, code: code, order: 0, context: context)
    }
}
