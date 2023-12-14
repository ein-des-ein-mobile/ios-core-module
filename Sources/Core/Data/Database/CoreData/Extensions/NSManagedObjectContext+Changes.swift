//
//  File.swift
//  
//
//  Created by Anton Bal’ on 13.12.2023.
//

import CoreData
import Combine

public extension NSManagedObjectContext {
    func publisher<T: NSManagedObject>(for managedObject: T) -> AnyPublisher<T, Never> {
        
        let notification = NSManagedObjectContext.didSaveObjectIDsNotification
        return NotificationCenter.default.publisher(for: notification, object: self)
            .compactMap { notification in
                if let updated = notification.userInfo?[NSUpdatedObjectIDsKey] as? Set<NSManagedObjectID>,
                   updated.contains(managedObject.objectID),
                   let updatedObject = self.object(with: managedObject.objectID) as? T {
                    return updatedObject
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
}
