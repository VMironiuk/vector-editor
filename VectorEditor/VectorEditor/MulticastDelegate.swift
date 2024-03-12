//
//  MulticastDelegate.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 12.03.2024.
//

import Foundation

public final class MulticastDelegate<T> {
    private var storedDelegates = NSHashTable<AnyObject>(options: .weakMemory)
        
    public var delegates: [T] {
        storedDelegates.allObjects as? [T] ?? []
    }
    
    public init() {}
    
    public func add(_ delegate: T) {
        storedDelegates.add(delegate as AnyObject)
    }
    
    public func remove(_ delegate: T) {
        storedDelegates.remove(delegate as AnyObject)
    }
}
