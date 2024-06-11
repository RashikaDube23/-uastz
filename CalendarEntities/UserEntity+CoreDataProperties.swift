//
//  UserEntity+CoreDataProperties.swift
//  Calendar
//
//  Created by Admin on 11/06/24.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var time: String?
    @NSManaged public var date: String?
    @NSManaged public var title: String?
    @NSManaged public var descriptiontext: String?

}

extension UserEntity : Identifiable {

}
