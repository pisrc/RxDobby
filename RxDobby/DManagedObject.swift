import Foundation
import CoreData


// MARK: - NSManagedObjectContext 확장

public protocol DManagedObjectContext {
}

extension DManagedObjectContext where Self: NSManagedObjectContext {
    
    public func insertNewObject<EntityType:NSManagedObject>(newObject: (EntityType) -> EntityType) -> EntityType {
        
        let entityName = String(EntityType)
        guard let obj = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self) as? EntityType else {
            fatalError("Type casting error. (\(EntityType.self))")
        }
        return newObject(obj)
    }
    
    public func selectAllForEntity(entityName: String, predicate: NSPredicate?) -> [AnyObject] {
        let request = NSFetchRequest(entityName: entityName)
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            return try executeFetchRequest(request)
        } catch {
            fatalError("\(error)")
        }
    }
    
    public func selectForEntity(entityName: String) -> AnyObject? {
        let records = selectAllForEntity(entityName, predicate: nil)
        return records.first
    }
    
    public func selectForEntity(entityName: String, predicate: NSPredicate) -> AnyObject? {
        let records = selectAllForEntity(entityName, predicate: predicate)
        return records.first
    }
    
    public func doSave(successHandler: (() -> ())? = nil) {
        do {
            try save()
            successHandler?()
        } catch {
            print("\(error)")
        }
    }
}
