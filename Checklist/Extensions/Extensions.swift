//
//  Extensions.swift
//  Checklist
//
//  Created by Jeffery Thomas on 11/24/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation

extension Array {

    func replaced(at index: Int, with element: Element) -> Array {
        var result = self
        result[index] = element
        return result
    }
    
}

extension Checklist {

    func renamed(to newTitle: String) -> Checklist {
        return Checklist(id: id, title: newTitle, items: items)
    }
    
}
