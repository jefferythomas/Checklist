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
    lazy var fileManager = FileManager.default

    enum ErrorX: Error {
        case noDocumentDirectoryInUserDomain
        case unableToEncodeIdentifier(identifer: String)
    }

    func fetchChecklistsWithIdentifier(_ identifier: String) -> Promise<ChecklistDataSet> {
        return DispatchQueue.main.promise {
            let URL = try self.URLForIdentifier(identifier)

            let data = try Data(contentsOf: URL)
            let JSON = try JSONSerialization.jsonObject(with: data)

            return try ChecklistDataSet.decode(JSON)
        } .recover { error -> ChecklistDataSet in
            if (error as NSError).code == NSFileReadNoSuchFileError {
                return ChecklistDataSet(identifier: identifier, checklists:[])
            }

            throw error
        }
    }

    func updateChecklists(_ dataSet: ChecklistDataSet) -> Promise<ChecklistDataSet> {
        return DispatchQueue.main.promise {
            let URL = try self.URLForIdentifier(dataSet.identifier)
            let JSON = try dataSet.JSONEncode()

            let data = try JSONSerialization.data(withJSONObject: JSON)
            try data.write(to: URL)

            return dataSet // JLT: For now, echo back the input
        }
    }

    func URLForIdentifier(_ identifier: String) throws -> URL {
        let directory: FileManager.SearchPathDirectory = .documentDirectory
        let domains: FileManager.SearchPathDomainMask = [.userDomainMask]
        let string = NSString(string: identifier)
        let allowedSet = CharacterSet.alphanumerics // JLT: Escape nearly everything

        guard let baseURL = fileManager.urls(for: directory, in: domains).first else {
            throw ErrorX.noDocumentDirectoryInUserDomain
        }

        guard let encodedString = string.addingPercentEncoding(withAllowedCharacters: allowedSet) else {
            throw ErrorX.unableToEncodeIdentifier(identifer: identifier)
        }

        return baseURL.appendingPathComponent(encodedString).appendingPathExtension("json")
    }
}
