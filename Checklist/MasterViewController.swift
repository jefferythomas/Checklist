//
//  MasterViewController.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    lazy var businessLogic = ChecklistBusinessLogic.sharedInstance
    lazy var checklists = ChecklistDataSet(items: [])
    lazy var defaultTitle = "Checklist"

    @IBAction func insertNewChecklist(_ sender: AnyObject) {
        insertNewChecklist(title: defaultTitle, at: IndexPath(row: 0, section: 0))
    }

    func insertNewChecklist(title: String, at indexPath: IndexPath) {
        businessLogic.insertNewChecklist(title: title, into: checklists, at: indexPath.row).then {
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        } .catch { error in
            print("Unable to insert new checklist to checklists: \(error)")
        }
    }

    func deleteChecklist(at indexPath: IndexPath) {
        businessLogic.deleteChecklist(from: checklists, at: indexPath.row).then {
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        } .catch { error in
            print("Unable to delete checklist to checklists: \(error)")
        }
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let addAction = #selector(insertNewChecklist(_:))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: addAction)

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = addButton

        self.businessLogic.loadAllChecklists(into: checklists).then {
            self.tableView.reloadData()
        } .catch { error in
            print("Unable to delete checklist to checklists: \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? true
        super.viewWillAppear(animated)
    }

    // MARK: Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "showDetail":
            if let indexPath = self.tableView.indexPathForSelectedRow  {
                let navigationController = segue.destination as? UINavigationController
                let detailViewController = navigationController?.topViewController as? DetailViewController
                let checklist = checklists.items[indexPath.row]

                detailViewController?.checklist = checklist
            }

        default:
            break
        }
    }

    // MARK: Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklists.items.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = checklists.items[indexPath.row].title
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
        case .delete: deleteChecklist(at: indexPath)
        case .insert: insertNewChecklist(title: defaultTitle, at: indexPath)
        default:      break
        }
    }

}
