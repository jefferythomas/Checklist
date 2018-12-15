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
        XCTAssert(dataSource.fileManager.enumerator(atPath: dataSource.baseUrl.path)?.allObjects.count ?? 0 <= 1)
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

        let item = try? JSONDecoder().decode(ChecklistItem.self, from: JSONSerialization.data(withJSONObject: json))

        XCTAssertEqual(item, ChecklistItem(title: "test", checked: true))
    }

    func testChecklistItemEncode() {
        let item = ChecklistItem(title: "test", checked: false)

        let json = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(item))

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

        let checklist = try? JSONDecoder().decode(Checklist.self, from: JSONSerialization.data(withJSONObject: json))

        XCTAssertEqual(checklist?.title, "test")
        XCTAssertEqual(checklist?.items.first, ChecklistItem(title: "test", checked: true))
    }

    func testChecklistEncode() {
        let checklist = Checklist(id: "id", title: "test", items: [ChecklistItem(title: "test", checked: true)])

        let json = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(checklist))

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

        dataSet.sort(by: >)
        XCTAssertEqual(dataSet.items, ["c", "b", "a"])
    }

    func testDataSetResetItems() {
        let dataSet = DataSet(items: ["a", "b", "c"])
        XCTAssertEqual(dataSet.items, ["a", "b", "c"])

        dataSet.sort(by: >)
        XCTAssertEqual(dataSet.items, ["c", "b", "a"])

        dataSet.sort(by: nil)
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
        } .then { dataSet -> ChecklistDataSetPromise in
            XCTAssertTrue(self.dataSource._hasChecklist(with: dataSet.items[0].id))
            return self.dataSource.delete(dataSet: dataSet)
        } .done { dataSet in
            XCTAssertFalse(self.dataSource._hasChecklist(with: dataSet.items[0].id))
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistById() {
        let ex = expectation(description: "testChecklistDataSourceCreateAndDeleteId")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { _ -> ChecklistDataSetPromise in
            XCTAssertTrue(self.dataSource._hasChecklist(with: id))
            return self.dataSource.delete(ids: [id])
        } .done { _ in
            XCTAssertFalse(self.dataSource._hasChecklist(with: id))
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistByTitle() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklistByTitle")

        firstly {
            self.dataSource.create()
        } .map { dataSet -> ChecklistDataSet in
            ChecklistDataSet(items: [Checklist(id: dataSet.items[0].id,
                                               title: "test",
                                               items: dataSet.items[0].items)])
        } .then { dataSet -> ChecklistDataSetPromise in
            self.dataSource.update(dataSet: dataSet)
        } .then { _ -> ChecklistDataSetPromise in
            self.dataSource.fetch(ChecklistDataSource.Criteria(titles: ["test"]))
        } .done { dataSet in
            XCTAssertEqual(dataSet.items.first?.title, "test")
            self.dataSource.delete(dataSet: dataSet)
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistByIdTitle() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklistByIdTitle")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .map { dataSet -> ChecklistDataSet in
            ChecklistDataSet(items: [Checklist(id: dataSet.items[0].id,
                                               title: "test",
                                               items: dataSet.items[0].items)])
        } .then { dataSet -> ChecklistDataSetPromise in
            self.dataSource.update(dataSet: dataSet)
        } .then { _ -> ChecklistDataSetPromise in
            self.dataSource.fetch(ChecklistDataSource.Criteria(ids: [id], titles: ["test"]))
        } .done { dataSet in
            XCTAssertEqual(dataSet.items.first?.title, "test")
            self.dataSource.delete(ids: [id])
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistByChecklist() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklistByChecklist")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { dataSet -> ChecklistDataSetPromise in
            self.dataSource.fetch(dataSet.items[0])
        } .done { dataSet in
            XCTAssertEqual(dataSet.items.count, 1)
            XCTAssertEqual(dataSet.items.first?.id, id)
            self.dataSource.delete(ids: [id])
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklists() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklists")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { _ -> ChecklistDataSetPromise in
            self.dataSource.fetch(ChecklistDataSource.Criteria())
        } .done { dataSet in
            XCTAssertTrue(dataSet.items.contains { checklist in checklist.id == id })
            self.dataSource.delete(ids: [id])
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testLoadAllChecklists() {
        let ex = expectation(description: "testLoadAllChecklists")
        let id = NSUUID().uuidString
        let logic = self.businessLogic

        firstly {
            logic.dataSource.create(id: id)
        } .then { _ -> Promise<[Checklist]> in
            logic.loadAllChecklists()
        } .done { checklists in
            XCTAssertEqual(checklists.count, 1)
            XCTAssertEqual(checklists[0].id, id)
            logic.dataSource.delete(ids: [id])
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testInsertNewChecklist() {
        let ex = expectation(description: "testInsertNewChecklist")
        let logic = self.businessLogic

        firstly {
            logic.insertNewChecklist(title: "test", at: 0)
        } .done { checklists in
            XCTAssertEqual(checklists.count, 1)
            XCTAssertEqual(checklists[0].title, "test")
            logic.dataSource.delete(ids: [logic.checklists[0].id])
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testDeleteChecklist() {
        let ex = expectation(description: "testDeleteChecklist")
        let id = NSUUID().uuidString
        let logic = self.businessLogic

        firstly {
            logic.dataSource.create(id: id)
        } .then { _ -> Promise<[Checklist]> in
            logic.loadAllChecklists()
        } .then { checklists -> Promise<[Checklist]> in
            XCTAssertEqual(checklists.count, 1)
            XCTAssertEqual(checklists[0].id, id)
            return logic.deleteChecklist(at: 0)
        } .done { _ in
            XCTAssertFalse(logic.dataSource._hasChecklist(with: id))
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testRenameChecklist() {
        let ex = expectation(description: "testRenameChecklist")
        let logic = businessLogic

        firstly {
            logic.insertNewChecklist(title: "test", at: 0)
        } .then { checklists -> Promise<[Checklist]> in
            XCTAssertEqual(checklists.count, 1)
            XCTAssertEqual(checklists[0].title, "test")
            return logic.renameChecklist(title: "renamed", at: 0)
        } .done { checklists -> () in
            XCTAssertEqual(checklists.count, 1)
            XCTAssertEqual(checklists[0].title, "renamed")
            logic.dataSource.delete(ids: [logic.checklists[0].id])
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testTearChecklist() {
        let ex = expectation(description: "testTearChecklist")
        let logic = businessLogic

        firstly {
            logic.dataSource.create()
        } .map { dataSet -> Checklist in
            Checklist(id: dataSet.items[0].id,
                      title: "checklist",
                      items: [ChecklistItem(title: "item", checked: true)])
        } .then { checklist -> ChecklistDataSetPromise in
            logic.dataSource.update(dataSet: DataSet(items: [checklist]))
        } .then { dataSet -> Promise<Void> in
            logic.checklists = dataSet.items
            XCTAssertTrue(logic.checklists[0].items[0].checked)
            return logic.tearChecklist(at: 0)
        } .done {
            XCTAssertFalse(logic.checklists[0].items[0].checked)
            logic.dataSource.delete(ids: [logic.checklists[0].id])
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testInsertNewChecklistItem() {
        let ex = expectation(description: "testInsertNewChecklistItem")
        let logic = businessLogic

        firstly {
            logic.dataSource.create()
        } .map { dataSet -> Checklist in
            Checklist(id: dataSet.items[0].id,
                      title: "checklist",
                      items: [])
        } .then { checklist -> ChecklistDataSetPromise in
            logic.dataSource.update(dataSet: DataSet(items: [checklist]))
        } .then { dataSet -> Promise<Void> in
            logic.checklists = dataSet.items
            return logic.insertNewChecklistItem(title: "test", at: 0, intoChecklistAt: 0)
        } .done {
            XCTAssertEqual(logic.checklists[0].items.count, 1)
            logic.dataSource.delete(ids: [logic.checklists[0].id])
        } .catch { error in
            XCTFail("error: \(error)")
        } .finally {
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

}

extension ChecklistDataSource {

    fileprivate func _hasChecklist(with id: String) -> Bool {
        return fileManager.fileExists(atPath: url(forId: id).path)
    }

}
