//
//  TasksViewController.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import UIKit

// FIXME: 1. Lack of dedicated place to setup controllers (DI)
// FIXME: 2. Business logic mixed with presentation
// FIXME: 3. Follow up to previous points: hard to test
// FIXME: 4. Lack of mechanism for sharing/caching data
// FIXME: 5. Too many responsibilites
// FIXME: 6. Multiply places of state mutation
final class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CreateTaskViewControllerDelegate {

    private enum ViewState {

        case empty, loading, ready
    }

    @IBOutlet private var emptyView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loaderIndicator: UIActivityIndicatorView!

    private let refreshControl = UIRefreshControl()

    // FIXME: Direct creation of service within controller scope, it should be assosaction in best scenario
    private let networkServie = NetworkService(baseURL: SharedConstant.networkURL)

    // FIXME: Model kept directly
    private var tasks = [Task]()
    private var viewState = ViewState.empty {
        didSet {
            switch self.viewState {
                case .empty:
                    self.emptyView.isHidden = false
                    self.tableView.isHidden = true
                    self.loaderIndicator.stopAnimating()
                case .loading:
                    self.emptyView.isHidden = true
                    self.tableView.isHidden = true
                    self.loaderIndicator.startAnimating()
                case .ready:
                    self.tableView.isHidden = false
                    self.emptyView.isHidden = true
                    self.loaderIndicator.stopAnimating()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.refreshControl = self.refreshControl

        self.refreshControl.addTarget(self, action: #selector(onReloadAction), for: .valueChanged)

        self.load()
    }

    // FIXME: Direct network request
    private func load(with completion: (() -> Void)? = nil) {
        let allTask = AllTaskNetworkTask()

        self.viewState = .loading

        self.networkServie.fetch(for: allTask, failure: { _ in
            completion?()
        }) { [weak self] tasks in
            guard let `self` = self else { return }
            // FIXME: Data layer manipulation
            self.tasks = tasks.sorted(by: { first, second -> Bool in
                if let firstDate = first.dueDate,
                    let secondDate = second.dueDate {
                    return firstDate < secondDate
                } else if first.dueDate != nil || second.dueDate != nil {
                    return true
                } else {
                    return false
                }
            })

            self.tableView.reloadData()

            if self.tasks.isEmpty {
                self.viewState = .empty
            } else {
                self.viewState = .ready
            }

            completion?()
        }
    }

    // MARK: - Actions
    @objc private func onReloadAction() {
        self.load { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    // FIXME: "Indirect" navigation knowledge due to segues
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let showController = segue.destination as? DetailTaskViewController,
            let taskIndex = self.tableView.indexPathForSelectedRow?.row {
            showController.task = self.tasks[taskIndex]
        } else if let createController = segue.destination as? CreateTaskViewController {
            createController.delegate = self
        }
    }

    @IBAction func unwindHere(segue: UIStoryboardSegue) { }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] _, index in
            guard let `self` = self, indexPath == index else { return }

            // FIXME: Direct network request
            let removeTask = RemoveTaskNetworkTask(identifier: self.tasks[index.row].id)
            self.networkServie.fetch(for: removeTask, success: { _ in
                print(#function)
            })

            // FIXME: Data layer manipulation
            self.tasks.remove(at: index.row)
            self.tableView.deleteRows(at: [index], with: .automatic)

            if self.tasks.isEmpty {
                self.viewState = .empty
            }
        }

        return [deleteAction]
    }

    // MARK: - UITablewViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row]

        // FIXME: Presentation logic manipulation
        cell.textLabel?.text = task.name

        if let taskDate = task.dueDate {
            let timeLeft = taskDate.timeIntervalSince1970 - Date().timeIntervalSince1970

            if timeLeft < 0 {
                cell.backgroundColor = .red
            } else if timeLeft < 72 * 3600 {
                cell.backgroundColor = .orange
            } else {
                cell.backgroundColor = .white
            }
        } else {
            cell.backgroundColor = .white
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }

    // MARK: - CreateTaskViewControllerDelegate
    func createTaskDidHappen(_ controller: CreateTaskViewController, with task: Task) {
        // FIXME: Data layer manipulation
        if let taskDate = task.dueDate, let taskIndex = self.tasks.index(where: { task -> Bool in
                if let dueDate = task.dueDate {
                    return dueDate > taskDate
                } else {
                    return true
                }
        }) {
            self.tasks.insert(task, at: taskIndex)
        } else {
            self.tasks.append(task)
        }

        self.tableView.reloadData()

        self.viewState = .ready
    }
}
