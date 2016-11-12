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
    lazy var defaultTitle = "Checklist"

    @IBAction func insertNewChecklist(_ sender: AnyObject) {
        insertNewChecklist(title: defaultTitle, at: IndexPath(row: 0, section: 0))
    }

    func insertNewChecklist(title: String, at indexPath: IndexPath) {
        businessLogic.insertNewChecklist(title: title, at: indexPath.row).then {
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        } .catch { error in
            print("Unable to insert new checklist to checklists: \(error)")
        }
    }

    func deleteChecklist(at indexPath: IndexPath) {
        businessLogic.deleteChecklist(at: indexPath.row).then {
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

        self.businessLogic.loadAllChecklists().then {
            self.tableView.reloadData()
        } .catch { error in
            print("Unable to load all checklists: \(error)")
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
            guard let indexPath = self.tableView.indexPathForSelectedRow else { break }
            guard let detailViewController = segue.detailViewControllerFromDestination() else { break }

            detailViewController.checklist = businessLogic.checklists[indexPath.row]

        default:
            break
        }
    }

    // MARK: Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessLogic.checklists.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = businessLogic.checklists[indexPath.row].title

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

extension UIStoryboardSegue {
    func detailViewControllerFromDestination() -> DetailViewController? {
        if let detailViewController = self.destination as? DetailViewController {
            return detailViewController
        }

        if let navigationController = self.destination as? UINavigationController,
            let detailViewController = navigationController.topViewController as? DetailViewController {
            return detailViewController
        }

        return nil
    }
}
