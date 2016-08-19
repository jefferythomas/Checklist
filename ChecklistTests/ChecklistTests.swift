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
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testChecklistItemInitWithChecked() {
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

        let title = (json as? [String: AnyObject])?["title"] as? String
        let checked = (json as? [String: AnyObject])?["checked"] as? Bool

        XCTAssertEqual(title, "test")
        XCTAssertEqual(checked, false)
    }

    func testChecklistInit() {
        let checklist = Checklist(title: "test", items: [])

        XCTAssertEqual(checklist.title, "test")
        XCTAssertEqual(checklist.items, [])
    }

    func testChecklistChecked() {
        var checklist = Checklist(title: "test", items: [ChecklistItem(title: "test", checked: false)])

        XCTAssertEqual(checklist.items.count, 1)
        XCTAssertEqual(checklist.items[0].checked, false)
        checklist.items[0].checked = true
        XCTAssertEqual(checklist.items[0].checked, true)
    }

    func testChecklistDecode() {
        let json: [String: Any] = ["title": "test", "items": [["title": "test", "checked": true]]]

        let checklist = try? Checklist.decode(json)

        XCTAssertEqual(checklist?.title, "test")
        XCTAssertEqual(checklist?.items.first, ChecklistItem(title: "test", checked: true))
    }

    func testChecklistEncode() {
        let checklist = Checklist(title: "test", items: [ChecklistItem(title: "test", checked: true)])

        let json = try? checklist.JSONEncode()

        let title = (json as? [String: AnyObject])?["title"] as? String
        let items = (json as? [String: AnyObject])?["items"] as? [[String: AnyObject]]
        let firstItemTitle = items?.first?["title"] as? String
        let firstItemChecked = items?.first?["checked"] as? Bool

        XCTAssertEqual(title, "test")
        XCTAssertEqual(firstItemTitle, "test")
        XCTAssertEqual(firstItemChecked, true)
    }

    func testChecklistDataSourceURLForIdentifier() {
        let dataSource = ChecklistDataSource()

        let URL = try? dataSource.URLForIdentifier("test")

        XCTAssertEqual(URL?.lastPathComponent, "test.json")
    }

    func testChecklistDataSourceURLForIdentifierWithSpecialCharacters() {
        let dataSource = ChecklistDataSource()

        let URL = try? dataSource.URLForIdentifier("test test./")

        XCTAssertEqual(URL?.lastPathComponent, "test%20test%2E%2F.json")
    }

    func testChecklistDataSourceStore() {
        let ex = expectation(description: "testChecklistDataSourceStore")

        let UUID = NSUUID().uuidString
        let checklist = Checklist(title: "test", items: [])
        let dataSet = ChecklistDataSet(identifier: UUID, checklists: [checklist])

        let dataSource = ChecklistDataSource()

        firstly {
            return dataSource.updateChecklists(dataSet)
        } .then { dataSet -> () in
            let URL = try dataSource.URLForIdentifier(dataSet.identifier)

            XCTAssertEqual(dataSet.checklists.count, 1)
            XCTAssertEqual(dataSet.checklists.first?.title, "test")

            XCTAssertTrue(dataSource.fileManager.fileExists(atPath: URL.path))
            try dataSource.fileManager.removeItem(at: URL)
            XCTAssertFalse(dataSource.fileManager.fileExists(atPath: URL.path))
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetch() {
        let ex = expectation(description: "testChecklistDataSourceFetch")

        let checklist = Checklist(title: "test", items: [])
        let dataSet = ChecklistDataSet(identifier: NSUUID().uuidString, checklists: [checklist])
        let dataSource = ChecklistDataSource()

        firstly {
            return dataSource.updateChecklists(dataSet)
        } .then { dataSet in
            return dataSource.fetchChecklistsWithIdentifier(dataSet.identifier)
        } .then { dataSet -> () in
            let URL = try dataSource.URLForIdentifier(dataSet.identifier)

            XCTAssertEqual(dataSet.checklists.count, 1)
            XCTAssertEqual(dataSet.checklists.first?.title, "test")

            XCTAssertTrue(dataSource.fileManager.fileExists(atPath: URL.path))
            try dataSource.fileManager.removeItem(at: URL)
            XCTAssertFalse(dataSource.fileManager.fileExists(atPath: URL.path))
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchCreate() {
        let ex = expectation(description: "testChecklistDataSourceFetchCreate")

        let dataSource = ChecklistDataSource()

        firstly {
            return dataSource.fetchChecklistsWithIdentifier(NSUUID().uuidString)
        } .then { dataSet -> () in
            let URL = try dataSource.URLForIdentifier(dataSet.identifier)

            XCTAssertEqual(dataSet.checklists.count, 0)

            XCTAssertFalse(dataSource.fileManager.fileExists(atPath: URL.path))
        } .always {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
        }
        
        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

}
