//
//  DetailTaskViewController.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import UIKit

final class DetailTaskViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var dueDateLabel: UILabel!

    // FIXME: Model directly kept
    var task: Task?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.task?.name
        self.descriptionLabel.text = self.task?.description
        self.dueDateLabel.text = self.task?.dueDate?.description
    }
}
