//
//  DataStructures.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/9/8.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

struct Queue<T> {
    var list = [T]()
    
    mutating func enqueue(_ element: T) {
          list.append(element)
    }
    
    mutating func dequeue() -> T? {
         if !list.isEmpty {
           return list.removeFirst()
         } else {
           return nil
         }
    }
    
    func peek() -> T? {
         if !list.isEmpty {
              return list[0]
         } else {
           return nil
         }
    }
    
    var isEmpty: Bool {
         return list.isEmpty
    }
    
    mutating func dequeueAll() -> [T] {
        if list.isEmpty {
            return []
        }else{
            var result:[T] = []
            result.append(contentsOf: self.list)
            self.list.removeAll()
            return result
        }
    }
}
