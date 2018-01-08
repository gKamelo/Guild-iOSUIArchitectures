//
//  DatePickerViewController.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate: class {

    func datePicker(_ controller: DatePickerViewController, with newDate: Date?)
}

final class DatePickerViewController: UIViewController {

    @IBOutlet private var datePicker: UIDatePicker!

    weak var delegate: DatePickerViewControllerDelegate?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.setupPresentation()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupPresentation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.datePicker.minimumDate = Date().addingTimeInterval(24 * 3600)
    }

    private func setupPresentation() {
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    // MARK: - Actions
    @IBAction func onBackgroundTapAction(_ sender: UITapGestureRecognizer) {
        self.delegate?.datePicker(self, with: nil)
    }

    @IBAction private func onCancelAction(_ sender: UIBarButtonItem) {
        self.delegate?.datePicker(self, with: nil)
    }

    @IBAction private func onDoneAction(_ sender: UIBarButtonItem) {
        self.delegate?.datePicker(self, with: self.datePicker.date)
    }
}
