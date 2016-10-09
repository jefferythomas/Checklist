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

typealias ChecklistDataSet = DataSet<Checklist>
typealias ChecklistDataSetPromise = Promise<ChecklistDataSet>

class ChecklistDataSource {
    lazy var fileManager = FileManager.default

    var baseUrl: URL {
        get {
            if _baseUrl == nil { _baseUrl = _ensureDirectory(_defaultBaseUrl()) }
            return _baseUrl!
        }

        set {
            _baseUrl = _ensureDirectory(newValue)
        }
    }

    func url(forId id: String) -> URL {
        return baseUrl.appendingPathComponent(id).appendingPathExtension("json")
    }

    func fetchChecklists() -> ChecklistDataSetPromise {
        return DispatchQueue.main.promise { () -> ChecklistDataSet in
            let enumerator = self.fileManager.enumerator(at: self.baseUrl, includingPropertiesForKeys: [])!

            let items = try enumerator.allObjects.map { url in
                return try Checklist._from(fileUrl: url as! URL)
            }

            return DataSet(items: items)
        }
    }

    func fetchChecklist(id: String) -> ChecklistDataSetPromise {
        return DispatchQueue.main.promise { () -> ChecklistDataSet in
            let checklist = try Checklist._from(fileUrl: self.url(forId: id))

            return DataSet(items: [checklist])
        }
    }

    func updateChecklists(_ dataSet: ChecklistDataSet) -> ChecklistDataSetPromise {
        return DispatchQueue.main.promise {
            for checklist in dataSet.items {
                let url = self.url(forId: checklist.id)
                let json = try checklist.JSONEncode()

                let data = try JSONSerialization.data(withJSONObject: json)
                try data.write(to: url)
            }

            return dataSet // JLT: For now, echo back the input
        }
    }

    func deleteChecklist(id: String) -> ChecklistDataSetPromise {
        return DispatchQueue.main.promise { () -> ChecklistDataSet in
            let url = self.url(forId: id)
            let checklist = try Checklist._from(fileUrl: url)
            try self.fileManager.removeItem(at: url)

            return DataSet(items: [checklist])
        }
    }

    // MARK: Private

    private var _baseUrl: URL?

    private func _defaultBaseUrl() -> URL {
        let urls = fileManager.urls(for: .documentDirectory, in: [.userDomainMask])
        return urls[0].appendingPathComponent("checklists", isDirectory: true)
    }

    private func _ensureDirectory(_ url: URL) -> URL {
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
            assert(isDir.boolValue, "\(url) exists, but is not a directory")
        } else {
            try! fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }

        return url
    }
}

private extension Checklist {
    static func _from(fileUrl: URL) throws -> Checklist {
        let data = try Data(contentsOf: fileUrl)
        let json = try JSONSerialization.jsonObject(with: data)
        return try Checklist.decode(json)
    }
}
