//
//  CreateTaskViewController.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import UIKit

protocol CreateTaskViewControllerDelegate: class {

    func createTaskDidHappen(_ controller: CreateTaskViewController, with task: Task)
}

// FIXME: 1. Business logic mixed with presentation
// FIMXE: 2. Too many responsibilites
final class CreateTaskViewController: UIViewController, UITextViewDelegate, DatePickerViewControllerDelegate {

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

    // FIXME: Direct network request
    private let networkServie = NetworkService(baseURL: SharedConstant.networkURL)

    // FIXME: Presentation logic
    private let dateFormatter = DateFormatter()
    private var currentDueDate: Date?

    weak var delegate: CreateTaskViewControllerDelegate?

    private var isCreating = false {
        didSet {
            if self.isCreating {
                self.loaderIndicator.startAnimating()
                self.createButton.isHidden = true
                self.titleTextField.isEnabled = false
                self.descriptionTextView.isEditable = false
            } else {
                self.loaderIndicator.stopAnimating()
                self.createButton.isHidden = false
                self.titleTextField.isEnabled = true
                self.descriptionTextView.isEditable = true
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dateFormatter.dateFormat = "dd/MM/yyyy"

        self.updateDescritpionField()
        self.updateCreateAvailablity()
        self.updateDateField()

        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShowNotification(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHideNotification(notification:)), name: .UIKeyboardWillHide, object: nil)
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
        self.createButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true)
    }

    private func updateDateField() {
        if let dueDate = self.currentDueDate {
            self.dueDateButton.setTitle(self.dateFormatter.string(from: dueDate), for: .normal)
        } else {
            self.dueDateButton.setTitle("Set due date", for: .normal)
        }
    }

    private func resetFields() {
        self.titleTextField.text = ""
        self.descriptionTextView.text = ""
        self.currentDueDate = nil
        self.dueDateButton.setTitle("Set due date", for: .normal)

        self.updateCreateAvailablity()
    }

    // MARK: - Keyboard
    // FIXME: Keyboard handling could be moved to separate class
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
        guard let title = self.titleTextField.text else { return }

        let description = self.descriptionTextView.text.isEmpty ? nil : self.descriptionTextView.text
        let createTask = CreateTaskNetworkTask(name: title, description: description, dueDate: self.currentDueDate)

        self.isCreating = true

        self.networkServie.fetch(for: createTask) { [weak self] task in
            guard let `self` = self else { return }

            self.isCreating = false
            self.resetFields()

            self.delegate?.createTaskDidHappen(self, with: task)
        }
    }

    @IBAction private func onTitleChangeAction(_ sender: UITextField) {
        self.updateCreateAvailablity()
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        self.updateDescritpionField()
    }

    // MARK: - DatePickerViewControllerDelegate
    func datePicker(_ controller: DatePickerViewController, with newDate: Date?) {
        controller.dismiss(animated: true, completion: nil)

        self.currentDueDate = newDate

        self.updateDateField()
    }
}
