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

    @IBAction func insertNewObject(_ sender: AnyObject) {
        self.insertObject(Date() as AnyObject, atIndexPath: IndexPath(row: 0, section: 0))
    }

    func insertObject(_ object: AnyObject, atIndexPath indexPath: IndexPath) {
        objects.insert(object, at: (indexPath as NSIndexPath).row)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    func deleteObjectAtIndexPath(_ indexPath: IndexPath) {
        objects.remove(at: (indexPath as NSIndexPath).row)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let addAction = #selector(insertNewObject(_:))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: addAction)

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? true
        super.viewWillAppear(animated)
    }

    // MARK: Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow  {
                let navigationController = segue.destination as? UINavigationController
                let detailViewController = navigationController?.topViewController as? DetailViewController
                let object = objects[(indexPath as NSIndexPath).row] as? Date

                detailViewController?.detailItem = object
            }
        }
    }

    // MARK: Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[(indexPath as NSIndexPath).row] as? Date
        cell.textLabel?.text = object?.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath)
    {
        switch editingStyle {
        case .delete: self.deleteObjectAtIndexPath(indexPath)
        case .insert: self.insertObject(Date() as AnyObject, atIndexPath: indexPath)
        default:      break
        }
    }

}
