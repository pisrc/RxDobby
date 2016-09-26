//
//  TestEntity.swift
//  RxDobby
//
//  Created by ryan on 9/26/16.
//  Copyright © 2016 kimyoungjin. All rights reserved.
//

import Foundation
import CoreData

final class TestEntity: NSManagedObject {

}

extension TestEntity {
    @NSManaged var int32Field: NSNumber?
    @NSManaged var stringField: String?
}
