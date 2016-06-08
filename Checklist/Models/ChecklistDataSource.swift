//
//  ChecklistDataSource.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/30/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import PromiseKit
import Decodable

class ChecklistDataSource {
    lazy var fileManager = NSFileManager.defaultManager()

    enum Error: ErrorType {
        case NoDocumentDirectoryInUserDomain
        case UnableToEncodeIdentifier(identifer: String)
    }

    func fetchChecklistsWithIdentifier(identifier: String) -> Promise<ChecklistDataSet> {
        return dispatch_promise {
            let URL = try self.URLForIdentifier(identifier)

            if let data = NSData(contentsOfURL: URL) {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                return try ChecklistDataSet.decode(json)
            } else {
                return ChecklistDataSet(identifier: identifier, checklists:[])
            }
        }
    }

    func storeChecklists(dataSet: ChecklistDataSet) -> Promise<ChecklistDataSet> {
        return dispatch_promise {
            let options: NSDataWritingOptions = []
            let URL = try self.URLForIdentifier(dataSet.identifier)
            let json = dataSet.encode()

            try NSJSONSerialization.dataWithJSONObject(json, options: []).writeToURL(URL, options: options)

            return dataSet
        }
    }

    func URLForIdentifier(identifier: String) throws -> NSURL {
        let directory: NSSearchPathDirectory = .DocumentDirectory
        let domains: NSSearchPathDomainMask = [.UserDomainMask]
        let string = NSString(string: identifier)
        let allowedSet = NSCharacterSet.alphanumericCharacterSet() // JLT: Escape nearly everything

        guard let baseURL = fileManager.URLsForDirectory(directory, inDomains: domains).first else {
            throw Error.NoDocumentDirectoryInUserDomain
        }

        guard let encodedString = string.stringByAddingPercentEncodingWithAllowedCharacters(allowedSet) else {
            throw Error.UnableToEncodeIdentifier(identifer: identifier)
        }

        return baseURL.URLByAppendingPathComponent(encodedString).URLByAppendingPathExtension("json")
    }
}
