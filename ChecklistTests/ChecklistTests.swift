//
//  ChecklistTests.swift
//  ChecklistTests
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import XCTest
import PromiseKit
@testable import Checklist

class ChecklistTests: XCTestCase {
    lazy var dataSource = ChecklistDataSource()
    lazy var businessLogic = ChecklistBusinessLogic()

    override func setUp() {
        dataSource = ChecklistDataSource()
        businessLogic = ChecklistBusinessLogic()

        let baseURL = URL(fileURLWithPath: "/tmp/ChecklistTests\(UUID().uuidString)/", isDirectory: true)

        dataSource.baseUrl = baseURL
        businessLogic.dataSource = dataSource
    }

    override func tearDown() {
        XCTAssertNil(dataSource.fileManager._enumerator(at:dataSource.baseUrl)?.nextObject())
        try? dataSource.fileManager.removeItem(at: dataSource.baseUrl)
        XCTAssertFalse(dataSource.fileManager.fileExists(atPath: dataSource.baseUrl.path))
    }

    func testChecklistItemInitWithTitle() {
        let item = ChecklistItem(title: "test", checked: false)

        XCTAssertEqual(item.title, "test")
        XCTAssertEqual(item.checked, false)
    }

    func testChecklistItemInitWithTitleChecked() {
        let item = ChecklistItem(title: "test", checked: true)

        XCTAssertEqual(item.title, "test")
        XCTAssertEqual(item.checked, true)
    }

    func testChecklistItemDecode() {
        let json: [String: Any] = ["title": "test", "checked": true]

        let item = try? ChecklistItem.decode(json)

        XCTAssertEqual(item, ChecklistItem(title: "test", checked: true))
    }

    func testChecklistItemDecodeArray() {
        let json = [["title": "test", "checked": true]]

        let items = try? [ChecklistItem].decode(json)

        XCTAssertEqual(items?.first, ChecklistItem(title: "test", checked: true))
    }

    func testChecklistItemEncode() {
        let item = ChecklistItem(title: "test", checked: false)

        let json = try? item.JSONEncode()

        let title = (json as? [String: Any])?["title"] as? String
        let checked = (json as? [String: Any])?["checked"] as? Bool

        XCTAssertEqual(title, "test")
        XCTAssertEqual(checked, false)
    }

    func testChecklistInit() {
        let checklist = Checklist(id: "id",
                                  title: "test",
                                  items: [ChecklistItem(title: "test", checked: false)])

        XCTAssertEqual(checklist.id, "id")
        XCTAssertEqual(checklist.title, "test")
        XCTAssertEqual(checklist.items, [ChecklistItem(title: "test", checked: false)])
    }

    func testChecklistDecode() {
        let json: [String: Any] = ["id": "id", "title": "test", "items": [["title": "test", "checked": true]]]

        let checklist = try? Checklist.decode(json)

        XCTAssertEqual(checklist?.title, "test")
        XCTAssertEqual(checklist?.items.first, ChecklistItem(title: "test", checked: true))
    }

    func testChecklistEncode() {
        let checklist = Checklist(id: "id", title: "test", items: [ChecklistItem(title: "test", checked: true)])

        let json = try? checklist.JSONEncode()

        let title = (json as? [String: Any])?["title"] as? String
        let items = (json as? [String: Any])?["items"] as? [[String: Any]]
        let firstItemTitle = items?.first?["title"] as? String
        let firstItemChecked = items?.first?["checked"] as? Bool

        XCTAssertEqual(title, "test")
        XCTAssertEqual(firstItemTitle, "test")
        XCTAssertEqual(firstItemChecked, true)
    }

    func testDataSet() {
        let dataSet = DataSet(items: ["a", "b", "c"])
        XCTAssertEqual(dataSet.items, ["a", "b", "c"])
    }

    func testDataSetSortItems() {
        let dataSet = DataSet(items: ["a", "b", "c"])
        XCTAssertEqual(dataSet.items, ["a", "b", "c"])

        dataSet.items.sort(by: >)
        XCTAssertEqual(dataSet.items, ["c", "b", "a"])
    }

    func testDataSetResetItems() {
        let dataSet = DataSet(items: ["a", "b", "c"])
        XCTAssertEqual(dataSet.items, ["a", "b", "c"])

        dataSet.items.sort(by: >)
        XCTAssertEqual(dataSet.items, ["c", "b", "a"])

        dataSet.reset()
        XCTAssertEqual(dataSet.items, ["a", "b", "c"])
    }

    func testChecklistDataSourceUrlForId() {
        let url = dataSource.url(forId: "test")

        XCTAssertEqual(url.lastPathComponent, "test.json")
    }

    func testChecklistDataSourceCreateAndDelete() {
        let ex = expectation(description: "testChecklistDataSourceCreateAndDelete")

        firstly {
            self.dataSource.create()
        } .then { dataSet -> ChecklistDataSet in
            XCTAssertTrue(self.dataSource._hasChecklist(with: dataSet.items[0].id))
            return dataSet
        } .then { dataSet in
            self.dataSource.delete(dataSet: dataSet)
        } .then { dataSet in
            XCTAssertFalse(self.dataSource._hasChecklist(with: dataSet.items[0].id))
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistById() {
        let ex = expectation(description: "testChecklistDataSourceCreateAndDeleteId")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { _ in
            XCTAssertTrue(self.dataSource._hasChecklist(with: id))
        } .then {
            self.dataSource.delete(ids: [id])
        } .then { _ in
            XCTAssertFalse(self.dataSource._hasChecklist(with: id))
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistByTitle() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklistByTitle")

        firstly {
            self.dataSource.create()
        } .then { dataSet in
            ChecklistDataSet(items: [Checklist(id: dataSet.items[0].id,
                                               title: "test",
                                               items: dataSet.items[0].items)])
        } .then { dataSet in
            self.dataSource.update(dataSet: dataSet)
        } .then { _ in
            self.dataSource.fetch(ChecklistDataSource.Criteria(titles: ["test"]))
        } .then { dataSet -> ChecklistDataSet in
            XCTAssertEqual(dataSet.items.first?.title, "test")
            return dataSet
        } .then { dataSet in
            self.dataSource.delete(dataSet: dataSet)
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistByIdTitle() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklistByIdTitle")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { dataSet in
            ChecklistDataSet(items: [Checklist(id: dataSet.items[0].id,
                                               title: "test",
                                               items: dataSet.items[0].items)])
        } .then { dataSet in
            self.dataSource.update(dataSet: dataSet)
        } .then { _ in
            self.dataSource.fetch(ChecklistDataSource.Criteria(ids: [id], titles: ["test"]))
        } .then { dataSet in
            XCTAssertEqual(dataSet.items.first?.title, "test")
        } .then {
            self.dataSource.delete(ids: [id])
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistByChecklist() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklistByChecklist")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { dataSet in
            self.dataSource.fetch(dataSet.items[0])
        } .then { dataSet -> () in
            XCTAssertEqual(dataSet.items.count, 1)
            XCTAssertEqual(dataSet.items.first?.id, id)
        } .then {
            self.dataSource.delete(ids: [id])
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklists() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklists")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { _ in
            self.dataSource.fetch(ChecklistDataSource.Criteria())
        } .then { dataSet in
            XCTAssertTrue(dataSet.items.contains { checklist in checklist.id == id })
        } .then {
            self.dataSource.delete(ids: [id])
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testLoadAllChecklists() {
        let ex = expectation(description: "testLoadAllChecklists")
        let id = NSUUID().uuidString
        let logic = self.businessLogic

        firstly {
            logic.dataSource.create(id: id)
        } .then { _ in
            logic.loadAllChecklists()
        } .then {
            XCTAssert(logic.checklists.count == 1 && logic.checklists[0].id == id )
        } .then {
           logic.dataSource.delete(ids: [id])
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testInsertNewChecklist() {
        let ex = expectation(description: "testInsertNewChecklist")
        let logic = self.businessLogic

        firstly {
            logic.insertNewChecklist(title: "test", at: 0)
        } .then {
            XCTAssert(logic.checklists.count == 1 && logic.checklists[0].title == "test")
        } .then {
            logic.dataSource.delete(ids: [logic.checklists[0].id])
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testDeleteChecklist() {
        let ex = expectation(description: "testDeleteChecklist")
        let id = NSUUID().uuidString
        let logic = self.businessLogic

        firstly {
            logic.dataSource.create(id: id)
        } .then { _ in
            logic.loadAllChecklists()
        } .then {
            XCTAssert(logic.checklists.count == 1 && logic.checklists[0].id == id)
        } .then {
            logic.deleteChecklist(at: 0)
        } .then {
            XCTAssert(logic.checklists.count == 0 && !logic.dataSource._hasChecklist(with: id))
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testRenameChecklist() {
        let ex = expectation(description: "testRenameChecklist")
        let logic = businessLogic

        firstly {
            logic.insertNewChecklist(title: "test", at: 0)
        } .then {
            XCTAssert(logic.checklists.count == 1 && logic.checklists[0].title == "test")
        } .then {
            logic.renameChecklist(title: "renamed", at: 0)
        } .then {
            XCTAssert(logic.checklists.count == 1 && logic.checklists[0].title == "renamed")
        } .then {
            logic.dataSource.delete(ids: [logic.checklists[0].id])
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

}

extension ChecklistDataSource {
    fileprivate func _hasChecklist(with id: String) -> Bool {
        return fileManager.fileExists(atPath: url(forId: id).path)
    }
}

extension FileManager {
    fileprivate func _enumerator(at url: URL) -> FileManager.DirectoryEnumerator? {
        return enumerator(at: url, includingPropertiesForKeys: [])
    }
}
