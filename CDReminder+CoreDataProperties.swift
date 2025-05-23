//
//  CDReminder+CoreDataProperties.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-21.
//
//

import Foundation
import CoreData


extension CDReminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDReminder> {
        return NSFetchRequest<CDReminder>(entityName: "CDReminder")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var dueDate: Date?
    @NSManaged public var list: String?
    @NSManaged public var notes: String?
    @NSManaged public var title: String?
    @NSManaged public var uuid: String?
    @NSManaged public var calendarIdentifier: String?
    @NSManaged public var eventIdentifier: String?
    @NSManaged public var isCompleted: Bool
}

extension CDReminder : Identifiable {

}
