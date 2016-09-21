import Foundation
import CoreData


// MARK: - NSManagedObjectContext 확장

public protocol DManagedObjectContext {
}

extension DManagedObjectContext where Self: NSManagedObjectContext {
    
    public func insertNewObject<EntityType:NSManagedObject>(_ newObject: (EntityType) -> EntityType) -> EntityType {
        
        let entityName = String(describing: EntityType.self)
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as? EntityType else {
            fatalError("Type casting error. (\(EntityType.self))")
        }
        return newObject(obj)
    }
    
    public func selectAllForEntity(_ entityName: String, predicate: NSPredicate?) -> [AnyObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            return try fetch(request)
        } catch {
            fatalError("\(error)")
        }
    }
    
    public func selectForEntity(_ entityName: String) -> AnyObject? {
        let records = selectAllForEntity(entityName, predicate: nil)
        return records.first
    }
    
    public func selectForEntity(_ entityName: String, predicate: NSPredicate) -> AnyObject? {
        let records = selectAllForEntity(entityName, predicate: predicate)
        return records.first
    }
    
    public func doSave(_ successHandler: (() -> ())? = nil) {
        do {
            try save()
            successHandler?()
        } catch {
            print("\(error)")
        }
    }
}
