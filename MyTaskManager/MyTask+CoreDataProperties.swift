//
//  Task+CoreDataProperties.swift
//  TaskManager
//
//  Created by 長橋和敏 on 2025/02/05.
//
//

import Foundation
import CoreData


extension MyTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyTask> {
        return NSFetchRequest<MyTask>(entityName: "MyTask")
    }

    @NSManaged public var title: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var timestamp: Date?

}

extension MyTask : Identifiable {

}
