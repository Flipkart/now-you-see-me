//
//  WeakRef.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 20/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 A Wrapper with weak reference to the specified object
 
 Can be used to store weak references to objects in arrays
 */
internal class WeakRef<T> where T: AnyObject & Hashable {
    /**
     Weak reference to the provided object
     */
    private(set) internal weak var value: T?

    /**
     Initializes the wrapper with a weak reference to the provided object
     - Parameters:
        - value: The object whose weak wrapper is required
     */
    internal init(_ value: T) {
        self.value = value
    }
}

extension WeakRef: Hashable {
    func hash(into hasher: inout Hasher) {
        // use value for creating hash
        hasher.combine(value)
    }

    static func == (lhs: WeakRef<T>, rhs: WeakRef<T>) -> Bool {
        // compare values
        return lhs.value == rhs.value
    }
}
