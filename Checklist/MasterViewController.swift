//
//  MasterViewController.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var objects = [AnyObject]()

    @IBAction func insertNewObject(sender: AnyObject) {
        self.insertObject(NSDate(), atIndexPath: NSIndexPath(forRow: 0, inSection: 0))
    }

    func insertObject(object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        objects.insert(object, atIndex: indexPath.row)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    func deleteObjectAtIndexPath(indexPath: NSIndexPath) {
        objects.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let addAction = #selector(insertNewObject(_:))
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: addAction)

        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.collapsed ?? true
        super.viewWillAppear(animated)
    }

    // MARK: Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow  {
                let navigationController = segue.destinationViewController as? UINavigationController
                let detailViewController = navigationController?.topViewController as? DetailViewController
                let object = objects[indexPath.row] as? NSDate

                detailViewController?.detailItem = object
            }
        }
    }

    // MARK: Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }

    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as? NSDate
        cell.textLabel?.text = object?.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView,
                            commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                            forRowAtIndexPath indexPath: NSIndexPath)
    {
        switch editingStyle {
        case .Delete: self.deleteObjectAtIndexPath(indexPath)
        case .Insert: self.insertObject(NSDate(), atIndexPath: indexPath)
        default:      break
        }
    }

}
