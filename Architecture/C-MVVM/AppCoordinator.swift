//
//  AppCoordinator.swift
//  C-MVVM
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import Foundation
import UIKit

// FIXME: Most of the time for leaves controllers there is no need to create separate coordinators
final class AppCoordinator: TasksViewControllerDelegate, CreateTaskViewControllerDelegate {

    private let networkService = NetworkService(baseURL: SharedConstant.networkURL)

    private weak var navigationController: UINavigationController?
    private weak var tasksViewController: TasksViewController?

    private var tasksViewModel: TasksViewModel?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.tasksViewController = navigationController?.topViewController as? TasksViewController
    }

    func start() {
        let tasksViewModel = TasksViewModel(networkService: self.networkService)

        self.tasksViewModel = tasksViewModel
        self.tasksViewController?.viewModel = tasksViewModel
        self.tasksViewController?.delegate = self
    }

    // MARK: - TasksViewControllerDelegate
    func tasksControllerShowCreate(_ controller: TasksViewController) {
        guard let createController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "create") as? CreateTaskViewController else { return }

        let createViewModel = CreateTaskViewModel(networkService: self.networkService)

        createController.delegate = self
        createController.viewModel = createViewModel

        self.navigationController?.present(createController, animated: true, completion: nil)
    }

    func tasksControllerShowDetail(_ controller: TasksViewController, for task: Task) {
        guard let detailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detail") as? DetailTaskViewController else { return }

        let detailViewModel = DetailTaskViewModel(task: task)

        detailController.viewModel = detailViewModel

        self.navigationController?.pushViewController(detailController, animated: true)
    }

    // MARK: - CreateTaskViewControllerDelegate
    func createTaskDidExit(_ controller: CreateTaskViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func createTaskDidHappen(_ controller: CreateTaskViewController, with task: Task) {
        self.tasksViewModel?.add(task)
    }
}
