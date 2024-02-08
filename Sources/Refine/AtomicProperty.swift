//
//  AtomicProperty.swift
//  
//
//  Created by 孟超 on 2024/2/8.
//

import Foundation

@propertyWrapper
struct AtomicProperty<Value> {
    var storage: Value
    let lock = NSLock()
    var wrappedValue: Value {
        get {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            return self.storage
        }
        set {
            self.lock.lock()
            self.storage = newValue
            self.lock.unlock()
        }
    }
    var projectedValue: Value {
        get {
            self.storage
        }
        set {
            self.storage = newValue
        }
    }
    init(wrappedValue: Value) {
        self.storage = wrappedValue
    }
    
}
