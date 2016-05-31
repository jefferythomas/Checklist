//
//  ChecklistTests.swift
//  ChecklistTests
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import XCTest
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

    func testChecklistItemInitWithoutChecked() {
        let item = ChecklistItem(title: "test")

        XCTAssertEqual(item.title, "test")
        XCTAssertEqual(item.checked, false)
    }

    func testChecklistItemInitWithChecked() {
        let item = ChecklistItem(title: "test", checked: true)

        XCTAssertEqual(item.title, "test")
        XCTAssertEqual(item.checked, true)
    }

    func testChecklistItemDecode() {
        do {
            let json = ["title": "test", "checked": true]

            let item = try ChecklistItem.decode(json)

            XCTAssertEqual(item, ChecklistItem(title: "test", checked: true))
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testChecklistItemDecodeArray() {
        do {
            let json = [["title": "test", "checked": true]]

            let items = try [ChecklistItem].decode(json)

            XCTAssertEqual(items.first, ChecklistItem(title: "test", checked: true))
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testChecklistItemEncode() {
        let item = ChecklistItem(title: "test", checked: false)

        let json = item.encode()

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
        let checklist = Checklist(title: "test", items: [ChecklistItem(title: "test", checked: false)])

        XCTAssertEqual(checklist.items.first?.checked, false)
        checklist.items.first?.checked = true
        XCTAssertEqual(checklist.items.first?.checked, true)
    }

    func testChecklistDecode() {
        do {
            let json = ["title": "test", "items": [["title": "test", "checked": true]]]

            let checklist = try Checklist.decode(json)

            XCTAssertEqual(checklist.title, "test")
            XCTAssertEqual(checklist.items.first, ChecklistItem(title: "test", checked: true))
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testChecklistEncode() {
        let checklist = Checklist(title: "test", items: [ChecklistItem(title: "test", checked: true)])

        let json = checklist.encode()

        let title = (json as? [String: AnyObject])?["title"] as? String
        let items = (json as? [String: AnyObject])?["items"] as? [[String: AnyObject]]
        let firstItemTitle = items?.first?["title"] as? String
        let firstItemChecked = items?.first?["checked"] as? Bool

        XCTAssertEqual(title, "test")
        XCTAssertEqual(firstItemTitle, "test")
        XCTAssertEqual(firstItemChecked, true)
    }
}
