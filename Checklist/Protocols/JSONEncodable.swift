//
//  JSONEncodable.swift
//  Checklist
//
//  Created by Jeffery Thomas on 6/8/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation

protocol JSONEncodable {
    func JSONEncode() throws -> AnyObject
}

extension CollectionType where Generator.Element: JSONEncodable {
    func JSONEncode() throws -> AnyObject {
        return try map { element in try element.JSONEncode() }
    }
}
