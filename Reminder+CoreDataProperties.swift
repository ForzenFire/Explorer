//
//  Reminder+CoreDataProperties.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-17.
//
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var title: String?
    @NSManaged public var notes: String?
    @NSManaged public var dueDate: Date?
    @NSManaged public var list: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var uuid: String?

}

extension Reminder : Identifiable {

}
