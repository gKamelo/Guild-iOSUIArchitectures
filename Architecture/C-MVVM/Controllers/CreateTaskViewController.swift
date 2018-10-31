//
//  CreateTaskViewController.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import UIKit

protocol CreateTaskViewControllerDelegate: class {

    func createTaskDidExit(_ controller: CreateTaskViewController)
    func createTaskDidHappen(_ controller: CreateTaskViewController, with task: Task)
}

// FIMXE: 1. Too many responsibilites
final class CreateTaskViewController: UIViewController, UITextViewDelegate, CreateTaskViewModelDelegate, DatePickerViewControllerDelegate {

    private struct Constant {

        static let minimalDescriptionHeight: CGFloat = 200
    }

    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var descriptionTextView: UITextView!

    @IBOutlet private var dueDateButton: UIButton!
    @IBOutlet private var createButton: UIButton!
    @IBOutlet private var loaderIndicator: UIActivityIndicatorView!

    @IBOutlet private var textViewHeightConstraint: NSLayoutConstraint!

    var viewModel: CreateTaskViewModel!

    weak var delegate: CreateTaskViewControllerDelegate?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.updateDescritpionField()
        }
    }

    private func updateDescritpionField() {
        self.textViewHeightConstraint.constant = max(Constant.minimalDescriptionHeight, self.descriptionTextView.contentSize.height)
        self.descriptionTextView.contentOffset = .zero
    }

    private func updateCreateAvailablity() {
        self.createButton.isEnabled = self.viewModel.canCreate
    }

    private func updateDateField() {
        self.dueDateButton.setTitle(self.viewModel.dueDateName, for: .normal)
    }

    // MARK: - CreateTaskViewModelDelegate
    func viewModelDidChange(to viewState: CreateTaskViewModel.ViewState) {
        switch viewState {
            case .`init`:
                self.updateDescritpionField()
                self.updateCreateAvailablity()
                self.updateDateField()
            case .creating:
                self.loaderIndicator.startAnimating()
                self.createButton.isHidden = true
                self.titleTextField.isEnabled = false
                self.descriptionTextView.isEditable = false
            case .created(let task):
                self.loaderIndicator.stopAnimating()
                self.createButton.isHidden = false
                self.titleTextField.isEnabled = true
                self.descriptionTextView.isEditable = true

                self.delegate?.createTaskDidHappen(self, with: task)
        }
    }

    func viewModelDidChange(to field: CreateTaskViewModel.Field) {
        switch field {
            case .title:
                self.titleTextField.text = self.viewModel.title
                self.updateCreateAvailablity()
            case .description:
                self.descriptionTextView.text = self.viewModel.description
            case .date:
                self.updateDateField()
        }
    }

    // MARK: - Keyboard
    @objc private func onKeyboardShowNotification(notification: Notification) {
        guard let keyboardHeiht = (notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect)?.height else { return }

        self.scrollView.contentInset.bottom = keyboardHeiht
        self.scrollView.scrollIndicatorInsets.bottom = keyboardHeiht
    }

    @objc private func onKeyboardHideNotification(notification: Notification) {
        self.scrollView.contentInset.bottom = 0
        self.scrollView.scrollIndicatorInsets.bottom = 0
    }

    // MARK: - Actions
    @IBAction func onDueDateAction(_ sender: UIButton) {
        let pickerController = DatePickerViewController()

        pickerController.delegate = self

        self.present(pickerController, animated: true, completion: nil)
    }

    @IBAction private func onCreateTask(_ sender: UIButton) {
        self.viewModel.create()
    }

    @IBAction private func onTitleChangeAction(_ sender: UITextField) {
        self.viewModel.updateTitle(with: sender.text)
    }

    @IBAction private func onExitAction(_ sender: UIBarButtonItem) {
        self.delegate?.createTaskDidExit(self)
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        self.viewModel.updateDescription(with: textView.text)

        self.updateDescritpionField()
    }

    // MARK: - DatePickerViewControllerDelegate
    func datePicker(_ controller: DatePickerViewController, with newDate: Date?) {
        controller.dismiss(animated: true, completion: nil)

        self.viewModel.updateDate(with: newDate)
    }
}
