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

            let data = try NSData(contentsOfURL: URL, options: [])
            let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: [])

            return try ChecklistDataSet.decode(JSON)
        } .recover { error -> ChecklistDataSet in
            if (error as NSError).code == NSFileReadNoSuchFileError {
                return ChecklistDataSet(identifier: identifier, checklists:[])
            }

            throw error
        }
    }

    func updateChecklists(dataSet: ChecklistDataSet) -> Promise<ChecklistDataSet> {
        return dispatch_promise {
            let URL = try self.URLForIdentifier(dataSet.identifier)
            let JSON = try dataSet.JSONEncode()

            let data = try NSJSONSerialization.dataWithJSONObject(JSON, options: [])
            try data.writeToURL(URL, options: [])

            return dataSet // JLT: For now, echo back the input
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
