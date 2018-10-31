//
//  TasksViewController.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import UIKit

// FIXME: 1. Lack of dedicated place to setup controllers (DI)
// FIXME: 2. Follow up to previous points: hard to test
// FIXME: 3. Lack of mechanism for sharing/caching data
// FIXME: 4. Too many responsibilites
final class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TasksViewModelDelegate, CreateTaskViewControllerDelegate {

    @IBOutlet private var emptyView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loaderIndicator: UIActivityIndicatorView!

    private let refreshControl = UIRefreshControl()

    private let viewModel = TasksViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.refreshControl = self.refreshControl

        self.refreshControl.addTarget(self, action: #selector(onReloadAction), for: .valueChanged)

        self.viewModel.delegate = self
        self.viewModel.load()
    }

    // MARK: - Actions
    @objc private func onReloadAction() {
        self.viewModel.load()
    }

    // FIXME: "Indirect" navigation knowledge due to segues
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let showController = segue.destination as? DetailTaskViewController,
            let taskIndex = self.tableView.indexPathForSelectedRow?.row {
            showController.viewModel = DetailTaskViewModel(task: self.viewModel.task(at: taskIndex))
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

            self.viewModel.delete(at: index.row)
        }

        return [deleteAction]
    }

    // MARK: - UITablewViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = self.viewModel.task(at: indexPath.row).name

        switch self.viewModel.taskState(at: indexPath.row) {
            case .overdue:
                cell.backgroundColor = .red
            case .endingSoon:
                cell.backgroundColor = .orange
            case .normal:
                cell.backgroundColor = .white
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfItems
    }

    // MARK: - TasksViewModelDelegate
    func viewModelDidChange(to viewState: TasksViewModel.ViewState) {
        switch viewState {
            case .`init`:
                self.emptyView.isHidden = true
                self.tableView.isHidden = true
                self.loaderIndicator.isHidden = true
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
                self.tableView.reloadData()

                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
        }
    }

    func viewModelDidRemoveItem(at index: Int) {
        self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
    }

    // MARK: - CreateTaskViewControllerDelegate
    func createTaskDidHappen(_ controller: CreateTaskViewController, with task: Task) {
        self.viewModel.add(task)
    }
}
